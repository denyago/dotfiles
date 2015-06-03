require 'rake'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'bin', 'yadr', 'vundle')
require File.join(File.dirname(__FILE__), 'lib', 'osx_tools_installer')

desc "Hook our dotfiles into system-standard positions."
task :install => [:submodule_init, :submodules] do
  puts
  puts "======================================================"
  puts "Welcome to YADR Installation."
  puts "======================================================"
  puts

  if mac_os_x?
    install_osx_dev_tools
    install_homebrew
  end

  install_rvm_binstubs

  # this has all the runcoms from this directory.
  file_operation(Dir.glob('git/*'))    if want_to_install?('git configs (color, aliases)')
  file_operation(Dir.glob('irb/*'))    if want_to_install?('irb/pry configs (more colorful)')
  file_operation(Dir.glob('ruby/*'))   if want_to_install?('rubygems config (faster/no docs)')
  file_operation(Dir.glob('ctags/*'))  if want_to_install?('ctags config (better js/ruby support)')
  file_operation(Dir.glob('tmux/*'))   if want_to_install?('tmux config')

  if want_to_install?('vim configuration (highly recommended)')
    file_operation(Dir.glob('{vim,vimrc}'))
    Rake::Task["install_vundle"].execute
  end

  if want_to_install?('hg configs and extensions')
    file_operation(Dir.glob('hg/*'))
    install_hg_extentions
  end

  Rake::Task['install_oh_my_zsh'].execute
  install_fonts

  if mac_os_x?
    install_term_theme
  end

  run_bundle_config

  success_msg("installed")
end

task :install_prezto do
  if want_to_install?('zsh enhancements & prezto')
    install_prezto
  end
end

task :install_oh_my_zsh do
  if want_to_install?('zsh enhancements & Oh My ZSH')
    install_oh_my_zsh
  end
end

task :update do
  Rake::Task["vundle_migration"].execute if needs_migration_to_vundle?
  Rake::Task["install"].execute
  #TODO: for now, we do the same as install. But it would be nice
  #not to clobber zsh files
end

task :submodule_init do
  unless ENV["SKIP_SUBMODULES"]
    run %{ git submodule update --init --recursive }
  end
end

desc "Init and update submodules."
task :submodules do
  unless ENV["SKIP_SUBMODULES"]
    puts "======================================================"
    puts "Downloading YADR submodules...please wait"
    puts "======================================================"

    run %{
      cd $HOME/.yadr
      git submodule update --recursive
      git clean -df
    }
    puts
  end
end

desc "Performs migration from pathogen to vundle"
task :vundle_migration do
  puts "======================================================"
  puts "Migrating from pathogen to vundle vim plugin manager. "
  puts "This will move the old .vim/bundle directory to"
  puts ".vim/bundle.old and replacing all your vim plugins with"
  puts "the standard set of plugins. You will then be able to "
  puts "manage your vim's plugin configuration by editing the "
  puts "file .vim/vundles.vim"
  puts "======================================================"

  Dir.glob(File.join('vim', 'bundle','**')) do |sub_path|
    run %{git config -f #{File.join('.git', 'config')} --remove-section submodule.#{sub_path}}
    # `git rm --cached #{sub_path}`
    FileUtils.rm_rf(File.join('.git', 'modules', sub_path))
  end
  FileUtils.mv(File.join('vim','bundle'), File.join('vim', 'bundle.old'))
end

desc "Runs Vundle installer in a clean vim environment"
task :install_vundle do
  puts "======================================================"
  puts "Installing and updating vundles."
  puts "The installer will now proceed to run PluginInstall to install vundles."
  puts "======================================================"

  puts ""

  vundle_path = File.join('vim','bundle', 'vundle')
  unless File.exists?(vundle_path)
    run %{
      cd $HOME/.yadr
      git clone https://github.com/gmarik/vundle.git #{vundle_path}
    }
  end

  Vundle::update_vundle
end

task :default => 'install'


private
def run(cmd)
  puts "[Running] #{cmd}"
  if ENV['DEBUG']
    `echo`
  else
    `#{cmd}`
  end
end

def number_of_cores
  if RUBY_PLATFORM.downcase.include?("darwin")
    cores = run %{ sysctl -n hw.ncpu }
  else
    cores = run %{ nproc }
  end
  puts
  cores.to_i
end

def run_bundle_config
  return unless system("which bundle")

  bundler_jobs = number_of_cores - 1
  puts "======================================================"
  puts "Configuring Bundlers for parallel gem installation"
  puts "======================================================"
  run %{ bundle config --global jobs #{bundler_jobs} }
  puts
end

def install_rvm_binstubs
  puts "======================================================"
  puts "Installing RVM Bundler support. Never have to type"
  puts "bundle exec again! Please use bundle --binstubs and RVM"
  puts "will automatically use those bins after cd'ing into dir."
  puts "======================================================"
  run %{ chmod +x $rvm_path/hooks/after_cd_bundler }
  puts
end

def install_hg_extentions
  run %{hg}
  if $?.success?
    puts '======================================================'
    puts 'Installing some Mercurial extensions'
    puts '======================================================'
    run %{
      cd $HOME/.yadr
      mkdir -p hg_external
      hg clone http://bitbucket.org/sjl/hg-prompt/   hg_external/hg-prompt
      hg clone https://bitbucket.org/yujiewu/hgflow  hg_external/hg-flow
    }
  else
    puts '======================================================'
    puts 'No Mercurial found :('
    puts '======================================================'
  end

  puts
  puts
end

def install_osx_dev_tools
  puts '======================================================'
  puts 'Installing OS X development tools/XCode'
  puts '======================================================'
  OSXToolsInstaller.new.install!
  puts
  puts
end

def install_homebrew
  run %{which brew}
  unless $?.success?
    puts "======================================================"
    puts "Installing Homebrew, the OSX package manager...If it's"
    puts "already installed, this will do nothing."
    puts "======================================================"
    run %{ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"}
  end

  brews_installed_list = `brew list`.split.grep(/\w+/)

  unless brews_installed_list.include? 'brew-cask'
    run %{brew install caskroom/cask/brew-cask}
  end

  brewz = {
    :original => %w{
       zsh ctags git hub tmux reattach-to-user-namespace the_silver_searcher
       mercurial postgresql wget mongodb redis gpg
       mc heroku-toolbelt htop imagemagick node tree graphviz
    },
    :cask => %w{
       firefox google-chrome skype dropbox
       ngrok iterm2 sourcetree rowanj-gitx time-out textmate
       istat-menus heroku-toolbelt slack rescuetime
       virtualbox the-unarchiver keepassx lisanet-gimp libreoffice
       tomighty quicklook-json quicklook-csv betterzipql
       horndis
    }
    # java android-studio
  }

  puts
  puts
  puts "======================================================"
  puts "Updating Homebrew."
  puts "======================================================"
  run %{brew update}
  puts
  puts

  brews_updates_list  = `brew outdated`.split("\n").
                          collect { |line| line.split.map(&:strip).first }

  casks_installed_list = `brew cask list`.split.grep(/\w+/)

  brew_install_list = brewz[:original].reject { |c| brews_installed_list.include? c }
  cask_install_list = brewz[:cask].reject     { |c| casks_installed_list.include? c }

  puts "======================================================"
  puts "Installing & Updating Homebrew packages..."
  puts "There may be some warnings."
  puts "======================================================"
  run %{brew install #{brew_install_list.join(' ')}}                  unless brew_install_list.empty?
  cask_env = 'HOMEBREW_CASK_OPTS="--appdir=~/Applications"'
  run %{#{cask_env} brew cask install #{cask_install_list.join(' ')}} unless cask_install_list.empty?
  vim_opts = '--custom-icons --override-system-vim --with-lua --with-luajit'
  run %{brew reinstall macvim #{vim_opts}}
  run %{brew link --overwrite macvim}
  run %{brew upgrade #{brews_updates_list.join(' ')}}                 unless brews_updates_list.empty?
  puts
  puts

  puts "====================================================="
  puts "Some tricks..."
  puts "====================================================="
  run %{sudo chown root:wheel `which htop`}
  run %{sudo chmod u+s `which htop`}
  run %{defaults write com.apple.finder QLEnableTextSelection -bool true && killall Finder}
  puts
  puts

end

def install_fonts
  puts "======================================================"
  puts "Installing patched fonts for Powerline/Lightline."
  puts "======================================================"
  run %{ cp -f $HOME/.yadr/fonts/* $HOME/Library/Fonts } if RUBY_PLATFORM.downcase.include?("darwin")
  run %{ mkdir -p ~/.fonts && cp ~/.yadr/fonts/* ~/.fonts && fc-cache -vf ~/.fonts } if RUBY_PLATFORM.downcase.include?("linux")
  puts
end

def install_term_theme
  puts "======================================================"
  puts "Installing iTerm2 solarized theme."
  puts "======================================================"
  run %{ /usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Light' dict" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ /usr/libexec/PlistBuddy -c "Merge 'iTerm2/Solarized Light.itermcolors' :'Custom Color Presets':'Solarized Light'" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ /usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Dark' dict" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ /usr/libexec/PlistBuddy -c "Merge 'iTerm2/Solarized Dark.itermcolors' :'Custom Color Presets':'Solarized Dark'" ~/Library/Preferences/com.googlecode.iterm2.plist }

  # If iTerm2 is not installed or has never run, we can't autoinstall the profile since the plist is not there
  if !File.exists?(File.join(ENV['HOME'], '/Library/Preferences/com.googlecode.iterm2.plist'))
    puts "======================================================"
    puts "To make sure your profile is using the solarized theme"
    puts "Please check your settings under:"
    puts "Preferences> Profiles> [your profile]> Colors> Load Preset.."
    puts "======================================================"
    return
  end

  # Ask the user which theme he wants to install
  message = "Which theme would you like to apply to your iTerm2 profile?"
  color_scheme = ask message, iTerm_available_themes

  return if color_scheme == 'None'

  color_scheme_file = File.join('iTerm2', "#{color_scheme}.itermcolors")

  # Ask the user on which profile he wants to install the theme
  profiles = iTerm_profile_list
  message = "I've found #{profiles.size} #{profiles.size>1 ? 'profiles': 'profile'} on your iTerm2 configuration, which one would you like to apply the Solarized theme to?"
  profiles << 'All'
  selected = ask message, profiles

  if selected == 'All'
    (profiles.size-1).times { |idx| apply_theme_to_iterm_profile_idx idx, color_scheme_file }
  else
    apply_theme_to_iterm_profile_idx profiles.index(selected), color_scheme_file
  end
end

def iTerm_available_themes
   Dir['iTerm2/*.itermcolors'].map { |value| File.basename(value, '.itermcolors')} << 'None'
end

def iTerm_profile_list
  profiles=Array.new
  begin
    profiles <<  %x{ /usr/libexec/PlistBuddy -c "Print :'New Bookmarks':#{profiles.size}:Name" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null}
  end while $?.exitstatus==0
  profiles.pop
  profiles
end

def ask(message, values)
  puts message
  while true
    values.each_with_index { |val, idx| puts " #{idx+1}. #{val}" }
    selection = STDIN.gets.chomp
    if (Float(selection)==nil rescue true) || selection.to_i < 0 || selection.to_i > values.size+1
      puts "ERROR: Invalid selection.\n\n"
    else
      break
    end
  end
  selection = selection.to_i-1
  values[selection]
end

def mac_os_x?
  RUBY_PLATFORM.downcase.include?("darwin")
end

def install_oh_my_zsh
  puts "======================================================"
  puts "Installing Oh My ZSH (ZSH Enhancements)..."
  puts "======================================================"

  run %{ ln -nfs "$HOME/.yadr/zsh/oh_my_zsh/overwrites/zshrc" "$HOME/.zshrc" }

  puts

  setup_zsh

  puts
  puts
end

def setup_zsh
  if ENV["SHELL"].include? 'zsh' then
    puts "Zsh is already configured as your shell of choice. Restart your session to load the new settings"
  else
    puts "Setting zsh as your default shell"
    if File.exists?("/usr/local/bin/zsh")
      if File.readlines("/private/etc/shells").grep("/usr/local/bin/zsh").empty?
        puts "Adding zsh to standard shell list"
        run %{ echo "/usr/local/bin/zsh" | sudo tee -a /private/etc/shells }
      end
      run %{ chsh -s /usr/local/bin/zsh }
    else
      run %{ chsh -s /bin/zsh }
    end
  end
end

def want_to_install? (section)
  if ENV["ASK"]=="true"
    puts "Would you like to install configuration files for: #{section}? [y]es, [n]o"
    STDIN.gets.chomp == 'y'
  else
    true
  end
end

def file_operation(files, method = :symlink)
  files.each do |f|
    file = f.split('/').last
    source = "#{ENV["PWD"]}/#{f}"
    target = "#{ENV["HOME"]}/.#{file}"

    puts "======================#{file}=============================="
    puts "Source: #{source}"
    puts "Target: #{target}"

    if File.exists?(target) && (!File.symlink?(target) || (File.symlink?(target) && File.readlink(target) != source))
      puts "[Overwriting] #{target}...leaving original at #{target}.backup..."
      run %{ mv "$HOME/.#{file}" "$HOME/.#{file}.backup" }
    end

    if method == :symlink
      run %{ ln -nfs "#{source}" "#{target}" }
    else
      run %{ cp -f "#{source}" "#{target}" }
    end

    puts "=========================================================="
    puts
  end
end

def needs_migration_to_vundle?
  File.exists? File.join('vim', 'bundle', 'tpope-vim-pathogen')
end


def list_vim_submodules
  result=`git submodule -q foreach 'echo $name"||"\`git remote -v | awk "END{print \\\\\$2}"\`'`.select{ |line| line =~ /^vim.bundle/ }.map{ |line| line.split('||') }
  Hash[*result.flatten]
end

def apply_theme_to_iterm_profile_idx(index, color_scheme_path)
  values = Array.new
  16.times { |i| values << "Ansi #{i} Color" }
  values << ['Background Color', 'Bold Color', 'Cursor Color', 'Cursor Text Color', 'Foreground Color', 'Selected Text Color', 'Selection Color']
  values.flatten.each { |entry| run %{ /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':#{index}:'#{entry}'" ~/Library/Preferences/com.googlecode.iterm2.plist } }

  run %{ /usr/libexec/PlistBuddy -c "Merge '#{color_scheme_path}' :'New Bookmarks':#{index}" ~/Library/Preferences/com.googlecode.iterm2.plist }
  run %{ defaults read com.googlecode.iterm2 }
end

def success_msg(action)
  puts ""
  puts "   _     _           _         "
  puts "  | |   | |         | |        "
  puts "  | |___| |_____  __| | ____   "
  puts "  |_____  (____ |/ _  |/ ___)  "
  puts "   _____| / ___ ( (_| | |      "
  puts "  (_______\_____|\____|_|      "
  puts ""
  puts "YADR has been #{action}. Please restart your terminal and vim."
end
