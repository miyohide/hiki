# -*- coding: utf-8 -*-
# $Id: test_util.rb,v 1.4 2006-05-29 13:39:10 fdiary Exp $

$:.unshift(File.join(File.dirname(__FILE__), '../hiki'))

require 'test/unit'
require 'hiki/util'

class TMarshal_Unit_Tests < Test::Unit::TestCase
  include Hiki::Util

  def setup
    @t1 = "123\n456\n"
    @t2 = "123\nabc\n456\n"
    @t3 = "123\n456\ndef\n"
    @t4 = "こんにちは、私の名前はわたなべです。\n私はJust Another Ruby Porterです。"
    @t5 = "こんばんは、私の名前はまつもとです。\nRubyを作ったのは私です。私はRuby Hackerです。"
  end

  def test_word_diff_html
    assert_equal( "123\n<ins class=\"added\">abc</ins>\n456\n", word_diff( @t1, @t2 ) )
    assert_equal( "<del class=\"deleted\">こんにちは</del><ins class=\"added\">こんばんは</ins>、私の<del class=\"deleted\">名前はわたなべです</del><ins class=\"added\">名前はまつもとです</ins>。\n<ins class=\"added\">Rubyを作ったのは私です。</ins>私は<del class=\"deleted\">Just Another </del>Ruby <del class=\"deleted\">Porter</del><ins class=\"added\">Hacker</ins>です。", word_diff( @t4, @t5) )
  end

  def test_word_diff_text
    assert_equal( "123\n{+abc+}\n456\n", word_diff_text( @t1, @t2 ) )
    assert_equal( "[-こんにちは-]{+こんばんは+}、私の[-名前はわたなべです-]{+名前はまつもとです+}。\n{+Rubyを作ったのは私です。+}私は[-Just Another -]Ruby [-Porter-]{+Hacker+}です。", word_diff_text( @t4, @t5 ) )
  end

  def test_unified_diff
    assert_equal( "@@ -1,2 +1,3 @@\n 123\n+abc\n 456\n", unified_diff( @t1, @t2 ) )
    assert_equal( "@@ -1,3 +1,2 @@\n 123\n-abc\n 456\n", unified_diff( @t2, @t1 ) )
  end

  def test_euc_to_utf8
    omit("do not use this method with Ruby1.9") if Object.const_defined?(:Encoding)
    hoge_euc = "\xA4\xDB\xA4\xB2"
    hoge_utf8 = "ほげ"
    fullwidth_wave_euc = "\xA1\xC1"
    fullwidth_wave_utf8 = "〜"
    assert_equal(hoge_utf8, euc_to_utf8(hoge_euc))
    assert_equal(fullwidth_wave_utf8, euc_to_utf8(fullwidth_wave_euc))
  end

  def test_utf8_to_euc
    omit("do not use this method with Ruby1.9") if Object.const_defined?(:Encoding)
    hoge_euc = "\xA4\xDB\xA4\xB2"
    hoge_utf8 = "ほげ"
    fullwidth_wave_euc = "\xA1\xC1"
    fullwidth_wave_utf8 = "〜"
    assert_equal(hoge_euc, utf8_to_euc(hoge_utf8))
    assert_equal(fullwidth_wave_euc, utf8_to_euc(fullwidth_wave_utf8))
  end
end
