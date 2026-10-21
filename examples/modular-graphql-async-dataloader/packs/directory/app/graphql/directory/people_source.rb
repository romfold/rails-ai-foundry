# frozen_string_literal: true

module Directory
  class PeopleSource < GraphQL::Dataloader::Source
    def initialize(tenant, role)
      @tenant = tenant
      @role = role
      super()
    end

    def fetch(ids)
      Current.set(tenant: @tenant) do
        ApplicationRecord.connected_to(role: @role, prevent_writes: true) do
          ApplicationRecord.connection_pool.with_connection(prevent_permanent_checkout: true) do
            attributes = { tenant: Current.tenant, role: ApplicationRecord.current_role, ids: ids }
            ActiveSupport::Notifications.instrument('directory.fetch', attributes) do
              records = Person.where(tenant: Current.tenant, id: ids).index_by(&:id)
              ids.map { |id| records[id.to_i] }
            end
          end
        end
      end
    end
  end
end
