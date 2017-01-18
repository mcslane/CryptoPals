require 'openssl'
require_relative 'challenge1.rb'
require_relative 'challenge9.rb'

module Challenge10
  def self.str_xor(str1, str2)
    unless str1.size == str2.size
      puts str1
      puts str2
      puts str1.size.to_s + ' ' + str2.size.to_s
    end


    bytes1 = str1.each_byte.to_a
    bytes2 = str2.each_byte.to_a

    bytes1.each_with_index.map { |byte, i| byte ^ bytes2[i] }.pack('c*')
  end

  def self.encrypt_CBC(str, key)
    cipher = OpenSSL::Cipher::AES.new(128, :ECB)
    cipher.encrypt
    cipher.padding = 0
    cipher.key = key

    blocks = get_blocks(str)
    init = Array.new(16, 0).pack('c*')

    encrypted = []
    blocks.each_with_index do |block, i|
      if i == 0
        xored_block = str_xor(init, block)
      else
        xored_block = str_xor(encrypted[i-1], block)
      end

      encrypted_block = cipher.update(xored_block)
      encrypted.push(encrypted_block)
    end

    encrypted.join
  end

  def self.decrypt_CBC(str, key)
    cipher = OpenSSL::Cipher::AES.new(128, :ECB)
    cipher.decrypt
    cipher.padding = 0
    cipher.key = key

    blocks = get_blocks(str)
    init = Array.new(16, 0).pack('c*')

    decrypted = []
    blocks.each_with_index do |block, i|
      decrypted_block = cipher.update(block)

      if i == 0
        xored_block = str_xor(init, decrypted_block)
      else
        xored_block = str_xor(blocks[i-1], decrypted_block)
      end
      
      decrypted.push(xored_block)
    end

    decrypted.join
  end

  def self.get_blocks(str)
    unless str.size % 16 == 0
      str = Challenge9::pkcs7_padding(str, (str.size / 16 + 1)*16)
    end

    result = []
    for i in (0...str.size/16)
      result.push(str[16*i, 16])
    end

    result
  end
end

if __FILE__ == $0
  key = "YELLOW SUBMARINE"
  in_file = File.new('input10.txt', 'r')
  b64 = ''
  in_file.each_line do |line|
    b64 += line
  end

  encrypted = Challenge1::base64_to_bytes(b64).pack('c*')
  puts Challenge10::decrypt_CBC(encrypted, key)
end