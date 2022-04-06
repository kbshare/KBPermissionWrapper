

Pod::Spec.new do |s|



  s.name         = "KBPermissionWrapper"
  s.version      = "0.0.2"
  s.summary      = "request permission"


  s.description  = "request permission"

  s.homepage     = "https://github.com/kbshare/KBPermissionWrapper.git"




   s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "zhang" => "1483488729@qq.com" }


  s.source       = { :git => "https://github.com/kbshare/KBPermissionWrapper.git", :tag => "#{s.version}" }
s.ios.deployment_target = '8.0'
s.prepare_command = <<-CMD
                       cat KBAddressBook.h
                      #  rm -r KBAddressBook.m
                       sudo touch a.text
                       echo '444444444444444444444'
                      bash new.sh
                   CMD
s.script_phase = { :name => 'Hello World', :script => 'echo "Hello World"' }



  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "KBPermissionWrapper", "*.{h,m,sh}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
