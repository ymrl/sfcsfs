module SFCSFS
  def SFCSFS.login(account,passwd)
    return Agent.login(account,passwd)
  end

  def SFCSFS.convert_encoding str
    if RUBY_VERSION >= "1.9"
      return str.force_encoding(Encoding::EUC_JP).encode(Encoding::UTF_8,:invalid=>:replace,:undef=>:replace)
    else
      require 'kconv'
      return Kconv.kconv(str,Kconv::UTF8,Kconv::EUC)
    end
  end
  def SFCSFS.convert_encoding_for_send str
    if RUBY_VERSION >= "1.9"
      return str.encode(Encoding::EUC_JP,:invalid=>:replace,:undef=>:replace)
    else
      require 'kconv'
      return Kconv.kconv(str,Kconv::EUC,Kconv::UTF8)
    end
  end
end

