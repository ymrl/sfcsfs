# encoding:UTF-8
require 'sfcsfs'
#require "#{File.dirname File.expand_path(__FILE__)}/../lib/sfcsfs.rb"
require 'pit'

SFS_CONFIG = Pit.get("sfcsfs", :require => {
  :account  => "your CNS account",
  :password => "your CNS password" })
ZANRYU_CONFIG = Pit.get("zanryu",:require => {
  :lecture  => "Lecture Name",
  :phone    => "Your Phone Number",
  :p_phone  => "Your Parents' Phone Number",
  :time     => "Time",
  :building => "Building Number",
  :floor    => "Floor Number",
  :room     => "Room Number",
  :reason   => "Your reason why you stay at SFC",
})

agent = SFCSFS::Agent.login(SFS_CONFIG[:account],SFS_CONFIG[:password])
agent.my_schedule.each do |lec|
  if lec.title.match(/#{ZANRYU_CONFIG[:lecture]}/)
    lec.send_stay_form({:phone    => ZANRYU_CONFIG[:phone   ],
                        :p_phone   => ZANRYU_CONFIG[:p_phone ],
                        :time     => ZANRYU_CONFIG[:time    ],
                        :building => ZANRYU_CONFIG[:building],
                        :floor    => ZANRYU_CONFIG[:floor   ],
                        :room     => ZANRYU_CONFIG[:room    ],
                        :reason   => ZANRYU_CONFIG[:reason  ],}
                      )
                                                   
    break
  end
end



