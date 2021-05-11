# frozen_string_literal: true

module GitFiles
  GitFile = Struct.new(:git_path, :relative_path, :inherited?) do
    include Comparable

    def i18n_segments
      @i18n_segments ||= relative_path.each_filename.map do |segment|
        without_ext = segment.sub(/\..*$/, '')
        I18n.t("files.#{without_ext}.name", default: without_ext).to_s.presence
      end.compact
    end

    def description
      I18n.t("files.#{basename_key}.description", default: nil)
    end

    def sortable_key
      @sortable_key ||= i18n_segments.map(&:downcase)
    end

    def basename_key
      relative_path.basename.to_s.sub(/\..*$/, '').to_s
    end

    def log
      # Reading the Git log fails, with Git complaining about an ambiguous argument, unless the
      # absolute path to the blob is provided.
      Git.open(Atlas.data_dir).log.path(git_path.to_s)
    end

    def <=>(other)
      sortable_key <=> other.sortable_key
    end
  end

  def self.glob(dataset, paths)
    return [] unless dataset.dataset_dir.exist?

    paths = paths.flatten
    prefix = dataset.dataset_dir.realpath.to_s
    parent = dataset.try(:parent)

    # Fetch a list of all matching files with the dataset dir.
    resolved_paths = dataset.send(:path_resolver).glob(paths)

    git_files = resolved_paths.map do |path|
      # Include only those which really appear with in the dataset dir, preventing possible abuse or
      # mistakes.
      if path.to_s.start_with?(prefix)
        GitFile.new(
          path.relative_path_from(Atlas.data_dir),
          path.relative_path_from(dataset.dataset_dir),
          false
        )
      elsif parent
        GitFile.new(
          path.relative_path_from(Atlas.data_dir),
          path.relative_path_from(dataset.parent.dataset_dir),
          true
        )
      end
    end

    git_files.compact.uniq(&:git_path)
  end
end
