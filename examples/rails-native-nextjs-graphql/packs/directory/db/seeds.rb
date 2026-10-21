# frozen_string_literal: true

Directory::Person.find_or_create_by!(tenant: 'a', name: 'Alice')
Directory::Person.find_or_create_by!(tenant: 'b', name: 'Bob')
