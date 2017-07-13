require 'rest-client'
require 'rqrcode'

response = RestClient.post 'https://login.weixin.qq.com/jslogin',
  { appid: 'wx782c26e4c19acffb',
    fun: 'new',
    lang: 'zh_CN',
    _: Time.now.to_i
  }

c = response.body.split(";")
status_code = c[0].gsub(/window.QRLogin.code = /,"")
uuid = c[1].gsub(/window.QRLogin.uuid = /,"").gsub("\"", "").strip

qrcode = RQRCode::QRCode.new('https://login.weixin.qq.com/l/' + uuid)
png = qrcode.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 120,
          border_modules: 4,
          module_px_size: 6,
          file: nil # path to write
          )
IO.write("wechat-qrcode.png", png.to_s)

puts response.body
puts Time.now.to_i
puts status_code
puts uuid

100000.times do
  response = RestClient.get "https://login.weixin.qq.com/cgi-bin/mmwebwx-bin/login?tip=1&uuid=#{uuid}&_=#{Time.now.to_i}"
  status_code = response.body.delete(";").gsub(/window.code=/, "")
  puts status_code
end
