#!/usr/bin/env ruby

# $Id: attach.cgi,v 1.4 2004-09-10 06:51:51 fdiary Exp $
# Copyright (C) 2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>

require 'cgi'
require 'nkf'
require 'hiki/config'
require 'hiki/util'

include Hiki::Util

def attach_file
  @conf = Hiki::Config::new
  set_conf(@conf)
  cgi = CGI.new

  params     = cgi.params
  page       = CGI.escape(params['p'][0] ? params['p'][0].read : 'FrontPage')
  command = params['command'][0] ? params['command'][0].read : 'view'
  command = 'view' unless ['view', 'edit'].index(command)
  r = ''

  if cgi.params['attach'][0] then
    raise unless params['p'][0] && params['attach_file'][0]

    filename   = File.basename(params['attach_file'][0].original_filename.gsub(/\\/, '/'))
    cache_path = "#{@conf.cache_path}/attach"

    begin
      Dir.mkdir(cache_path) unless test(?e, cache_path.untaint)
      attach_path = "#{cache_path}/#{page}"
      Dir.mkdir(attach_path) unless test(?e, attach_path)
      path = "#{attach_path}/#{CGI.escape(NKF.nkf('-e', filename))}"
      open(path.untaint, "wb") do |f|
        f.print params['attach_file'][0].read
      end
      r << "FILE        = #{path}\n"
      r << "SIZE        = #{File.size(path)} bytes\n"
    rescue Exception
      r << "#$! (#{$!.class})\n"
      r << $@.join( "\n" )
    ensure
      send_updating_mail(page, 'attach', r) if @conf.mail_on_update
      redirect(cgi, "#{@conf.index_page}?c=#{command}&p=#{page}")
    end
  elsif cgi.params['detach'][0] then
    attach_path = "#{@conf.cache_path}/attach/#{page}"

    begin
      Dir.foreach(attach_path) do |file|
        next unless params["file_#{file}"][0]
        path = "#{attach_path}/#{file}"
        if FileTest::file?(path) and params["file_#{file}"][0].read
          File::unlink(path)
          r << "FILE        = #{path}\n"
        end
      end
      Dir::rmdir(attach_path) if 2 == Dir::entries(attach_path)
    rescue Exception
      r << "#$! (#{$!.class})\n"
      r << $@.join( "\n" )
    ensure
      send_updating_mail(page, 'detach', r) if @conf.mail_on_update
      redirect(cgi, "#{@conf.index_page}?c=#{command}&p=#{page}")
    end
  end
end

def redirect(cgi, url)
  head = {'type' => 'text/html',
         }
   print cgi.header(head)
   print %Q[
            <html>
            <head>
            <meta http-equiv="refresh" content="0;url=#{url}">
            <title>moving...</title>
            </head>
            <body>Wait or <a href="#{url}">Click here!</a></body>
            </html>]
end

attach_file
