# Copyright (C) 2005 Kazuhiko <kazuhiko@fdiary.net>
# based on joesaisan's idea <http://joesaisan.tdiary.net/20050222.html#p02>

def note_orig_page
  if /\A#{Regexp.escape(note_prefix)}/ =~ @page
    hiki_anchor(escape($'), page_name($'))
  end
end

add_menu_proc do
  if /\A#{Regexp.escape(note_prefix)}/ =~ @page then
    hiki_anchor(escape( $' ), h(label_note_orig) )
  else
    page = note_prefix + @page
    text = @db.load( page )
    if text.nil? || text.empty?
      @conf['note.template'] ||= label_note_template_default
      %Q|<a href="#{@conf.cgi_name}?c=create;key=#{escape(page)};text=#{escape(@conf['note.template'])}">#{h(label_note_link)}</a>|
    else
      hiki_anchor(escape(page), h(label_note_link))
    end
  end
end if @page and auth?

def saveconf_note
  if @mode == 'saveconf' then
    @conf['note.template'] = @request.params['note.template']
  end
end

add_conf_proc('note', label_note_config) do
  saveconf_note
  @conf['note.template'] ||= label_note_template_default
  str = <<-HTML
  <h3 class="subtitle">#{label_note_template}</h3>
  <p><textarea name="note.template" cols="60" rows="8">#{h(@conf['note.template'])}</textarea></p>
  HTML
  str
end
