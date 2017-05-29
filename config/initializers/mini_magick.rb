MiniMagick.configure do |config|
  # Require ImageMagick, since the "auto_orient" feature in GraphicsMagick
  # doesn't seem to behave properly.
  config.cli = :imagemagick
end
