class FileChecker
  def self.perform
    file_checker = FileChecker.new
    return if file_checker.media_directory_path_exist?

    Logger.error(
      "File path #{Config.configuration.file_path.inspect}"\
      ' does not exist. Use --media-folder [Folder] to change'
    )
    abort
  end

  private

  def media_directory_path_exist?
    File.exist?(Config.configuration.media_directory_path)
  end
end
