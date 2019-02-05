class Uploader
  include BashHelper

  attr_accessor :make_mkv, :upload_path, :rip_path, :movie_name, :done_path
  def initialize(make_mkv)
    self.make_mkv = make_mkv
    self.upload_path = build_upload_path
    self.done_path = build_done_path
    self.movie_name = Config.configuration.movie_name
    @success = false
  end

  def uploading_path
    if type == :movie
      File.expand_path("#{upload_path}/../Uploading/Movies")
    elsif type == :tv
      File.expand_path("#{upload_path}/../Uploading/TV Shows")
    else
      raise 'Well this is occward we could not figure out what the type of movie this'
    end
  end

  def upload_path
    return @upload_path if @upload_path.to_s != ''
    return File.join(%w[/share Multimedia Movies]) if type == :movie
    return File.join(['/share', 'Multimedia', 'TV Shows']) if type == :tv

    raise 'Well this is occward you some how manage to make the upload path nil'
  end

  def mount
    if Config.configuration.upload_protocol == :ftp

    elsif Config.configuration.upload_protocol == :afp

    end
  end

  def start_upload
    ripped_files = Dir[make_mkv.rip_path + '/*']
    return if ripped_files.empty?

    create_upload_path
    fork do
      retried_once = false
      begin
        scp = Config.configuration.scp
        Logger.debug("ripped_files: #{ripped_files.join(', ')}")
        system!("rsync #{Config.configuration.scp_info}")

        # ripped_files.each do |ripped_file|
        #   Logger.info "Uploading #{ripped_file} to #{Config.configuration.scp_info}"
        #   remote_path = ripped_file.gsub(make_mkv.rip_path(safe: false), upload_path)
        #   scp.upload!(ripped_file, remote_path, recursive: true) do |_ch, name, sent, total|
        #     percentage = format('%.2f', sent.to_f / total.to_f * 100) + '%'
        #     Logger.debug("#{name} #{percentage}")
        #   end
        # end
        @success = true
        delete_rip_path!
        Notification.slack(
          "Finished Uploading file #{upload_path}",
          "#{ripped_files.join(', ')} -> #{upload_path}",
          message_color: 'green'
        )
        Logger.success "Finished Uploading file #{ripped_files.join(', ')} #{upload_path}"
        move_file_into_done_path
      rescue Interrupt, BashError => exception
        raise exception if retried_once

        Logger.warning(
          "#{exception.message} for #{movie_name}. Executing Retry"
        )
        retried_once = true
        retry
      rescue StandardError => exception
        Notification.slack(
          "Failure to upload #{ripped_files.join(', ')}",
          exception.message,
          message_color: 'red'
        )
        raise exception
      end
    end
  end

  def success?
    @success == true
  end

  def delete_rip_path!
    return make_mkv.delete_rip_path! if success?

    Logger.warning(
      "Could not delete #{movie_name}, have not successfully uploaded files"
    )
  end

  private

  def create_upload_path
    system!(
      "ssh -t #{Config.configuration.scp_info} "\
      "'mkdir -p #{Shellwords.escape(upload_path)}'"
    )
  end

  def move_file_into_done_path
    system!(
      "ssh -t #{Config.configuration.scp_info} "\
      "'mkdir -p #{Shellwords.escape(done_path)}'"
    )
    system!(
      "ssh -t #{Config.configuration.scp_info} "\
      "'mv #{Shellwords.escape(upload_path)} #{Shellwords.escape(done_path)}'"
    )
    Logger.success "File has been moved  #{upload_path} #{done_path}"
  end

  def build_upload_path
    File.join(
      if Config.configuration.type == :tv
        [
          Config.configuration.uploading_path,
          Config.configuration.movie_name,
          Config.configuration.tv_season_to_word,
          Config.configuration.disc_number_to_word
        ]
      else
        [Config.configuration.uploading_path, Config.configuration.movie_name]
      end
    )
  end
end
