Deface::Override.new :virtual_path  => 'account/login',
                     :name          => 'hide-login-form',
                     :surround      => '#login-form',
                     :text          => <<-HTML
<% if RedmineOmniauthCas.enabled? && RedmineOmniauthCas.cas_server.present? %>
<div style="text-align:center; margin:15px">
  <em class=info>
    <%= link_to_function "ou s'authentifier par login / mot de passe", "$('#login-form-container').show(); $(this).hide();" %>
  </em>
</div>
<div id="login-form-container" style="display:none">
  <%= render_original %>
</div>
<% else %>
<%= render_original %>
<% end %>
HTML
