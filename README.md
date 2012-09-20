# SFCSFS

SFCSFS is a SFC-SFS Scraping Library. SFC-SFS is an internal website for Keio Univ. Shounan Fujisawa Campus.

## Installation

Add this line to your application's Gemfile:

    gem 'sfcsfs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sfcsfs

## Usage

    config = Pit.get("sfcsfs", :require => {
        :account  => "your CNS account",
        :password => "your CNS password"
    })

    # Login to SFC-SFS
    agent = SFCSFS.login(config[:account],config[:password])

    # Get all classes of this semester and shows
    list = agent.all_classes_of_this_semester

    # Show name of these
    list.each do |e|
      puts e.title
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
