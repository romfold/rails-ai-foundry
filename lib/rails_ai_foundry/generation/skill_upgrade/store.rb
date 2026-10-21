# frozen_string_literal: true

require 'base64'
require 'digest'
require 'json'
require 'securerandom'
require_relative '../file_installer'

module RailsAIFoundry
  module Generation
    module SkillUpgrade
      class Store < FileInstaller
        def snapshot(path)
          ensure_safe(path, :file)
          return nil unless File.exist?(@file_system.absolute(path))

          content = File.open(@file_system.absolute(path), File::RDONLY | File::NOFOLLOW) { |file| file.binmode.read }
          { 'content' => Base64.strict_encode64(content), 'sha256' => Digest::SHA256.hexdigest(content),
            'mode' => File.stat(@file_system.absolute(path)).mode & 0o777 }
        end

        def self.content(bytes, mode = 0o644)
          { 'content' => Base64.strict_encode64(bytes), 'sha256' => Digest::SHA256.hexdigest(bytes), 'mode' => mode }
        end

        def self.digest(value)
          Digest::SHA256.hexdigest(JSON.generate(value))
        end

        def json(path)
          data = snapshot(path)
          raise InstallationError, "Missing upgrade artifact: #{path}" unless data

          JSON.parse(Base64.strict_decode64(data.fetch('content')))
        rescue JSON::ParserError, ArgumentError, KeyError
          raise InstallationError, "Invalid upgrade artifact: #{path}"
        end

        def write_json(path, value)
          replace(path, snapshot(path), self.class.content("#{JSON.pretty_generate(value)}\n", 0o600))
        end

        def replace(path, before, after)
          current = snapshot(path)
          return if current == after
          raise InstallationError, "Changed file blocks recovery: #{path}" unless current == before

          create_ancestors(File.dirname(path))
          if after
            publish(path, current, after)
          else
            File.unlink(@file_system.absolute(path))
            sync_directory(File.dirname(path))
          end
        end

        def private_directory(path)
          create_ancestors(path)
          File.chmod(0o700, @file_system.absolute(path))
        end

        def children(path)
          ensure_safe(path, :directory)
          return [] unless File.directory?(@file_system.absolute(path))

          @file_system.children(path).sort
        end

        def lock
          File.open(@file_system.root, File::RDONLY) do |file|
            unless file.flock(File::LOCK_EX | File::LOCK_NB)
              raise InstallationError, 'Another skill writer is active; retry after it finishes.'
            end

            yield
          ensure
            file.flock(File::LOCK_UN)
          end
        end

        private

        def publish(path, before, data)
          temporary = "#{path}.upgrade-#{SecureRandom.hex(8)}"
          bytes = decode(data, path)

          write_temporary(temporary, bytes, data.fetch('mode'))
          raise InstallationError, "Changed file blocks replacement: #{path}" unless snapshot(path) == before

          File.rename(@file_system.absolute(temporary), @file_system.absolute(path))
          sync_directory(File.dirname(path))
        ensure
          File.unlink(@file_system.absolute(temporary)) if temporary && File.file?(@file_system.absolute(temporary))
        end

        def decode(data, path)
          bytes = Base64.strict_decode64(data.fetch('content'))
          raise InstallationError, "Invalid snapshot: #{path}" unless Digest::SHA256.hexdigest(bytes) == data['sha256']

          bytes
        end

        def write_temporary(path, bytes, mode)
          flags = File::WRONLY | File::CREAT | File::EXCL | File::NOFOLLOW
          File.open(@file_system.absolute(path), flags, 0o600) do |file|
            file.binmode
            file.write(bytes)
            file.chmod(mode)
            file.flush
            file.fsync
          end
        end

        def sync_directory(path)
          File.open(@file_system.absolute(path), File::RDONLY, &:fsync)
        end
      end
    end
  end
end
