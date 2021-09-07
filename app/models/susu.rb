class Susu < ApplicationRecord

  serialize :descriptions, Array
  enum status: [:created_, :ongoing_, :ended_, :archived_]
  after_initialize :set_default_status, :if => :new_record?

  # Relationships
  has_many :susu_transactions
  has_many :susu_memberships
  has_many :users, through: :susu_memberships
  has_many :susu_invites

  # Validations
  validates :members_count, presence: true
  validates :days_per_round, presence: true
  validates :payin_amount, presence: true
  validates :payout_amount, presence: true
  validates :fees, presence: true
  validates :started_at, presence: true
  validates :status, presence: true

  def set_default_status
    self.status ||= :created_
  end


  #after_create :create_membership_and_invitation, :create_invitation

  #Create a Susu membership
  def create_membership user, is_admin 
    if user.present?        
      if is_admin == true

        #Create membership    
        membership = SusuMembership.new admin: is_admin, 
                                        collected: false,
                                        user_id: user.id,
                                        susu_id: self.id,
                                        payout_round: 1
        unless membership.save   #Model validation will complain if already a member
          return membership.errors[:susu_id].first + "'#{self.name.capitalize}'"       
        end

      else #User is not admin

        #Check if Susu count limit is reached
        message = Susu.susu_limit_check user
        if message
          return message
        end

        #Create membership
        #membership_count = SusuMembership.where(susu_id: self.id).count
        admin_membership = SusuMembership.where(susu_id: self.id, admin: true).first
        admin_round = admin_membership.payout_round   
        membership = SusuMembership.new admin: is_admin, 
                                        collected: false,
                                        user_id: user.id,
                                        susu_id: self.id,
                                        payout_round: admin_round
        admin_membership.payout_round = admin_round + 1
        unless !membership.save && admin_membership.save #Model validation will complain if already a member
          return membership.errors[:susu_id].first + "'#{self.name.capitalize}'"       
        end

        #Update Susu when a new membership is created
        update_susu_with_member

        #Create notification for members not including current
        memberships = SusuMembership.where(susu_id: self.id).where.not(user_id: user.id)
        memberships.each do |membership|        
          notification = create_notification self.id, membership[:user_id], user.id, 
                              SusuNotification.notice_types[:joined_], 
                              "#{user.username} joined Susu #{self.name}"
        end
      end
      return
    else
      return "Oops! Something went wrong. Please try again later"
    end
  end

  #Check if user has reached the maximum number of active Susus allowed
  #Note: Class method starts with self.
  def self.susu_limit_check user
    count = user.susus.where(status: Susu.statuses[:created_])
                  .or( user.susus.where(status: Susu.statuses[:ongoing_])).count
    puts count
    unless  count < 5
      return "You cannot participate in more than 5 Susus at the same time"
    end 
  end

  #Create invitation for each invited user
  #Note: Instance method is plain (not self.)
  def create_invitation sender, invited_users
    if invited_users.present? && sender.present?
      invited_users.each do |invited_user_id|

        user = User.find_by_id(invited_user_id)
        if user.present?

          # Sender can"t be recipient
          unless sender.id == user.id

            member = SusuMembership.where(susu_id: self.id, user_id: user.id)
            pending_invite = SusuInvite.where(susu_id: self.id, sender_id: sender.id, recipient_id: user.id, accepted: false)

            #Make sure user not already susu member
            unless member.present? 
              #if user does have pending invite from this sender, create invite 
              unless pending_invite.present?  
                invite = SusuInvite.new accepted: false,
                                        susu_id: self.id, 
                                        sender_id: sender.id, 
                                        recipient_id: user.id
                invite.save
              end

              # Notify user
              create_notification self.id, user.id, sender.id, 
                                  SusuNotification.notice_types[:invited_], 
                                  "#{sender.username} invited you to join Susu #{self.name}"
            end
          end
        end
      end
    end
  end

  #Update Susu values when a new member is added
  def update_susu_with_member
    susu = self
    days_per_round = susu.days_per_round
    participants_count = susu.members_count + 1 
    payout_amount = susu.payin_amount.to_f * participants_count 
    ended_at = susu.started_at + (days_per_round * participants_count).days

    susu.update members_count: participants_count,
                rounds_count: participants_count,
                days_per_round: days_per_round,
                payout_amount: payout_amount,
                ended_at: ended_at
    susu.save
  end

  #Create a susu notification for a user
  def create_notification susu_id, user_id, sender_id, notice_type, notice
    susu_notification = SusuNotification.create susu_id: susu_id,
                                                notified_by_id: sender_id,
                                                notice_type: notice_type,
                                                smx_transaction_id: nil
    notification = Notification.create read: false,
                                       user_id: user_id,
                                       notice: notice,
                                       noticeable: susu_notification
  end

end
