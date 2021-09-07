
# Create user_id object and assign to it the user_id of the picture model
Paperclip.interpolates :user_id do |attachment, style|
	attachment.instance.user_id
end

Paperclip.interpolates :user_first_letter do |attachment, style|
	attachment.instance.user.first_name[0].upcase
end

Paperclip.interpolates :parameterize_file_name do |attachment, style|
    model = attachment.instance
    if model.is_a?(User)
    	"#{model.first_name}_#{model.last_name}"
    end
end