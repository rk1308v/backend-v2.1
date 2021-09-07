class GenerateUsernameService  
  def initialize(username)
    @username = get_username(username)
  end


  def set_username
    check_user
    if check_user.present?
      username = "#{get_username(@username)}#{get_user_code(@lat_username.username)}"
    else 
      username = get_username(@username) 
    end
    username.downcase
  end

  private

  def check_user 
   @lat_username = User.where("username like  ? " , "#{get_username(@username)}%").last
  end

  def get_user_code(username)
    n = username.scan(/\d+|[A-Z]+/i).last
    if numeric?(n)
      n.to_i + 1    
    else
      1
    end
  end

  def get_username(username) 
    ending = username.scan(/\d+/).last
    n = username.chomp(ending)
  end

  def numeric? string
    true if Integer(string) rescue false
  end

end
