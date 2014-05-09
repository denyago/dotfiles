##
# Determines way of installing Xcode Command Line Tools for OS X 10.8+
#
# Example:
#
#   OSXToolsInstaller.new.install!
#
# Borrowed from https://github.com/boxen/boxen-web/blob/b26abd0d681129eba0b5f46ed43110d873d8fdc2/app/views/splash/script.sh.erb
class OSXToolsInstaller

  # Triggers CLI Tools installation or exits with code '1'.
  def install!
    if cli_tools_installed?
      puts 'Looks like Xcode/CLI Tools are already installed'
    else
      case osx_version
        when '10.8' then install_for_108
        when '10.9' then install_for_109
        else fail_install
      end
    end
  end

  private

  # Returns String with OS X version. If it's not possible to determine - string is blank.
  def osx_version
    @osx_version ||= `sw_vers | grep ProductVersion | cut -f 2 -d ':'  | awk ' { print $1; } '`.strip rescue ''
  end

  def cli_tools_installed?
    File.exists?('/usr/bin/gcc')
  end

  def fail_install
    puts "Your OS X version is '#{osx_version}', but it must be Mountain Lion or greater!"
    exit 1
  end

  def install_for_108
    puts "
Since you are running OS X 10.8, you will need to install Xcode and the
Command Line Tools to continue.

  1. Go to the App Store and install Xcode.
  2. Start Xcode.
  3. Click on Xcode in the top left corner of the menu bar and click on
     Preferences.
  4. Click on the Downloads tab.
  5. Click on the Install button next to Command Line Tools.'
"
    wait_for_tools_installed
  end

  def install_for_109
    puts "
Since you are running OS X 10.9, you will need to install the Command
Line Tools.

  1. You should see a pop-up asking you to install them in a moment.
  2. Click Install!'
"
    wait_for_tools_installed
  end

  def wait_for_tools_installed
    puts "While you are installing them, I'll wait... or hit Ctrl+C to stop me."
    while not cli_tools_installed?
      sleep 60
    end
  end
end
