# Copyright (C) 2005 Kazuhiko <kazuhiko@fdiary.net>

def saveconf_edit_user
  if @mode == 'saveconf' then
    @conf['user.auth'] = @request.params['user.auth'].to_i
    user_list = {}
    (@conf['user.list'] ||= []).sort.each do |name, pass|
      unless @request.params["#{escape(name)}_remove"]
        password = @request.params["#{escape(name)}_pass"]
        unless password.empty?
          user_list[name] = crypt_password(password)
        else
          user_list[name] = pass
        end
      end
    end
    @conf['user.list'] = user_list

    @request.params['user.list'].each_line do |line|
      if /^([^\s]+)\s+([^\s]+)/ =~ line
        name = $1
        pass = $2
        unless @conf['user.list'].has_key?(name) && /^[\w\d\-]+$/ =~ name
          @conf['user.list'][name] = crypt_password(pass)
        end
      end
    end
  end
  @conf['user.auth'] ||= 1
end

add_conf_proc('user', label_edit_user_config) do
  saveconf_edit_user
  str = <<-HTML
  <h3 class="subtitle">#{label_edit_user_title}</h3>
  <p>
    <table>
      <tr>
        <td>#{label_edit_user_delete}</td><td>#{label_edit_user_name}</td><td>#{label_edit_user_new_password}</td>
      </tr>
      #{(@conf['user.list'] || {}).sort.collect { |i, j| "<tr><td><input type=\"checkbox\" name=\"#{escape(i)}_remove\"></td><td>#{i}</td><td><input type=\"text\" name=\"#{escape(i)}_pass\" value=\"\"></td></tr>" }.join("\n")}
    </table>
  </p>
  <h3 class="subtitle">#{label_edit_user_add_title}</h3>
  <p>#{label_edit_user_description}</p>
  <p><textarea name="user.list" cols="40" rows="10"></textarea></p>
  <h3 class="subtitle">#{label_edit_user_auth_title}</h3>
  <p>#{label_edit_user_auth_description}</p>
  <p><select name="user.auth">
  HTML
  label_edit_user_auth_candidate.each_index{ |i|
    str << %Q|<option value="#{i}"#{@conf['user.auth'] == i ? ' selected' : ''}>#{label_edit_user_auth_candidate[i]}</option>\n|
  }
  str << "</select></p>\n"
  str
end

def auth?
  return false if @conf['user.auth'] == 0 && !@user
  return true
end

def crypt_password(passwd)
  salt = [rand(64),rand(64)].pack("C*").tr("\x00-\x3f","A-Za-z0-9./")
  passwd.crypt(salt)
end

export_plugin_methods(:auth?)
