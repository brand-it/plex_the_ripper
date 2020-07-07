Zeitwerk::Loader.new.tap do |loader|
  Dir[Application.root.join('app', '*')].each do |dir|
    loader.push_dir(dir)
  end
  loader.push_dir(Application.root.join('lib'))
  loader.setup
end
