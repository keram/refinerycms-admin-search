require 'rubygems'
require 'refinery/searchable_record'

require 'active_record'
require 'globalize'

class User < ActiveRecord::Base
end

class Page < ActiveRecord::Base
  has_many :page_parts
end

class PagePart < ActiveRecord::Base
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  create_table :pages do |t|
  end

  create_table :page_parts do |t|
    t.integer :page_id
  end

  create_table :users do |t|
    t.string :username
    t.string :email
  end
end

describe Refinery::SearchableRecord do
  describe 'Searchable Model' do
    context 'with simple searchable attributes' do

      before do
        User.class_eval do
          extend Refinery::SearchableRecord
          acts_like_searchable :username, :email
        end
      end

      it 'responds to search_by.. methods' do
        expect( User ).to respond_to(:search_by, :search_by_username, :search_by_email)
      end

      describe 'search_by' do
        it 'returns ActiveRecord::Relation' do
          expect( User.search_by nil ).to be_kind_of(ActiveRecord::Relation)
          expect( User.search_by 'test' ).to be_kind_of(ActiveRecord::Relation)
        end

        context 'invalid params' do
          it 'does not include like clause to sql' do
            # empty string
            expect( User.search_by('').to_sql ).to eq('SELECT "users".* FROM "users"')

            # too short string
            expect( User.search_by('a').to_sql ).to eq('SELECT "users".* FROM "users"')

            # nil and more complex query
            expect( User.where(id: 1).search_by(nil).order(id: :desc).to_sql ).to eq('SELECT "users".* FROM "users"  WHERE "users"."id" = 1  ORDER BY "users"."id" DESC')

            # not existing searchable attribute
            expect( User.search_by('test', 'not_existing_attr').to_sql ).to eq('SELECT "users".* FROM "users"')
          end
        end

        context 'valid params' do
          it 'include like clause to sql' do
            # empty string
            expect( User.search_by('lorem').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."username" LIKE \'lorem%\')')

            # not existing searchable attribute
            expect( User.search_by('test', 'email').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."email" LIKE \'test%\')')
          end

          it 'does not include % at end of string if there already is % or _' do
            expect( User.search_by('lorem%').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."username" LIKE \'lorem%\')')
            expect( User.search_by('lorem_').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."username" LIKE \'lorem_\')')
          end
        end
      end

      describe 'search_by_XY' do
        it 'returns ActiveRecord::Relation' do
          expect( User.search_by_username nil ).to be_kind_of(ActiveRecord::Relation)
        end

        it 'add like clause to sql query' do
          expect( User.search_by_username(nil).to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."username" LIKE NULL)')
          expect( User.search_by_username('test').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."username" LIKE \'test\')')
        end
      end
    end
  end
end
