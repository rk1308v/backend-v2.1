class Api::V1::PicturesController < Api::V1::BaseController
    before_action :set_picture, only: [:show, :update, :destroy]

    def_param_group :picture do
        param :picture, Hash, required: true, action_aware: true do
            param :user_id, Integer, required: true, allow_nil: false
            param :avatar, String, required: true, allow_nil: false
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Update base64 picture
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :PUT, '/pictures/update_picture_base64', 'Update profile picture with base64 encoding'
    param_group :picture
    def update_picture_base64
        if !@user.picture.present?
            @picture = Picture.create(user_id: @user.id)
        else
            @picture = @user.picture
        end

        image = Picture.parse_avatar picture_base64_params[:avatar][:data]
        image.original_filename = picture_base64_params[:avatar][:filename]

        if @picture.update(avatar: image)
            render json: @picture
        else
            render json: @picture.errors, status: :unprocessable_entity
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Update picture using mulipart image
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :PATCH, '/pictures/update_picture','Update profile pic'
    param_group :picture
    def update_picture 
        @picture  = @user.picture
        if @picture.present?
            @picture.update_attribute("avatar", picture_param[:avatar])
            render json: { status: 200, message: "avatar successfully updated" }
        else 
            @picture = Picture.new(user_id: @user.id, avatar: picture_param[:avatar])
            @picture.save
            render json: { status: 200, message: "avatar successfully created" }
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get profile picture - small size
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/profile_picture','Profile Picture'
    def profile_picture
        user_avatar = @user.picture.avatar.url(:thumb)
        if user_avatar.present?
            render json: {status: 200, updated_at: @user.picture.updated_at, avatar: user_avatar}
        else 
            render json: {status: 200, message: "Image not present" }
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get profile picture - big size
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/big_profile_picture','Big Profile Picture'
    def big_profile_picture
        user_avatar = @user.picture.avatar.url(:preview)
        if user_avatar.present?
            render json: {status: 200, updated_at: @user.picture.updated_at, avatar: user_avatar}
        else 
            render json: {status: 200, message: "Image not present" }
        end
    end

    #api :GET, '/pictures', 'List Pictures'
    def index
        @pictures = Picture.page(params[:page]).per(params[:per])
        render json: @pictures
    end

    # api :GET, '/pictures/:id', 'Show Picture'
    # def show
    #   render json: @picture
    # end

    # api :POST, '/pictures', 'Create Picture'
    # param_group :picture
    # def create
    #   @picture = Picture.new(picture_params)

    #   if @picture.save
    #     render json: @picture, status: :created, location: @picture
    #   else
    #     render json: @picture.errors, status: :unprocessable_entity
    #   end
    # end

    # api :PUT, '/pictures/:id', 'Update Picture'
    # param_group :picture
    # def update
    #   if @picture.update(picture_params)
    #     render json: @picture
    #   else
    #     render json: @picture.errors, status: :unprocessable_entity
    #   end
    # end

    # api :DELETE, '/pictures/:id', 'Destroy Picture'
    # def destroy
    #   @picture.destroy
    # end

    private
    # Only allow a trusted parameter "white list" through.
    def picture_param
        params.require(:user).permit(:avatar)
    end

    def picture_base64_params
        params.require(:user).permit(:avatar => [:data , :filename])
    end
end
