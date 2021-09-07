<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>

  # Callbacks
  <% attributes.select(&:token?).each do |attribute| -%>
  has_secure_token<% if attribute.name != "token" %> :<%= attribute.name %><% end %>
  <% end -%>
  <% if attributes.any?(&:password_digest?) -%>
  has_secure_password
  <% end -%>

  # Relationships
  <% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %><%= ', required: true' if attribute.required? %>
  <% end -%>
  
  # Validations

end
<% end -%>
