Pod::Spec.new do |s|
    s.name          =   "Slidey"
    s.version       =   "0.0.1"
    s.summary    =   "Slide view controller"
    s.license        =   "MIT"
    s.author         =   { "Govi" => "govi@email.com"}
    s.source         =   { :git => 'https://github.com/govi/Slidey.git', :tag => '0.0.1' }
    s.platform       =   :ios, '5.0'
    s.source_files  =   'Slidey', 'Slidey/**/*.{h,m}'
    s.resources     =   'res/**/*.png'
    s.frameworks   =   'CodeGraphics'
    s.requires_arc  =   true
    s.homepage     =   'https://github.com/govi/Slidey'
end