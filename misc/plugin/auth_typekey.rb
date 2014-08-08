# Copyright (C) 2005 TAKEUCHI Hitoshi
#
#

require 'hiki/auth/typekey'
require 'hiki/session'

@conf['typekey.token'] ||= ''

def auth?
  return true if @conf['typekey.token'].empty?
  session_id = @request.cookies['typekey_session_id']
  session_id && Session.new(@conf, session_id).check
end

def auth_typekey
  tk = TypeKey.new(@conf['typekey.token'], '1.1')
  ts =    @request.params['ts']
  email = @request.params['email']
  name =  @request.params['name']
  nick =  @request.params['nick']
  sig =   @request.params['sig']
  page =  @request.params['p'] || 'FrontPage'

  if ts and email and name and nick and sig and tk.verify(email, name, nick, ts, sig)
    session = Session.new(@conf)
    session.user = nick
    session.save
    self.cookies << typekey_cookie('typekey_session_id', session.session_id)
  end

  redirect(@cgi, "#{@conf.cgi_name}?#{page}", self.cookies)
end


def login_url
  tk = TypeKey.new(@conf['typekey.token'])
  return_url = "#{@conf.index_url}?c=plugin;plugin=auth_typekey;p=#{@page}"
  tk.getLoginUrl(return_url)
end

def typekey_cookie(name, value, max_age = Session::MAX_AGE)
  Hiki::Cookie.new( {
    'name' => name,
    'value' => value,
    'path' => self.cookie_path,
  })
end

add_body_enter_proc(Proc.new do
  if !auth?
    label_auth_typekey_login
  elsif @user
    <<EOS
<div class="hello">
#{sprintf(label_auth_typekey_hello, h(@user))}
</div>
EOS
  end
end)

def saveconf_auth_typekey
  if @mode == 'saveconf' then
    @conf['typekey.token'] = @request.params['typekey.token']
  end
end

add_conf_proc('auth_typekey', label_auth_typekey_config) do
  saveconf_auth_typekey
  str = <<-HTML
  <h3 class="subtitle">#{label_auth_typekey_token}</h3>
  <p>#{label_auth_typekey_token_msg}</p>
  <p><input name="typekey.token" size="40" value="#{h(@conf['typekey.token'])}"></p>
  HTML
  str
end
