# Set the encoding
Encoding.default_internal = Encoding::UTF_8

require 'bundler/setup'
require 'rack/contrib/try_static'
require 'rack/contrib/not_found'

# Set up asset compression
use Rack::Deflater

Bundler.require(:default)

# Ensure the site is served from the correct location and the headers are appropriate
use Rack::TryStatic,
  urls: %w[/],
  root: 'build',
  try: ['index.html', '/index.html'],
  header_rules: [
    ['atom.xml', { 'Content-Type' => 'application/atom+xml' }],
    [['xml'], { 'Content-Type' => 'application/xml' }],
    [['html'],  { 'Content-Type' => 'text/html; charset=utf-8' }],
    [['css'],   { 'Content-Type' => 'text/css' }],
    [['js'],    { 'Content-Type' => 'text/javascript' }],
    [['png'],   { 'Content-Type' => 'image/png' }],
    ['/assets', { 'Cache-Control' => 'public, max-age=31536000' }],
  ]

# 404s should be sent to that simple page we created above
run Rack::NotFound.new('build/404.html')