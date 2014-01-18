require 'refinery/searchable_record'
require 'active_record'
require 'globalize'

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
  translates :title
end

class Page < ActiveRecord::Base
  translates :title
  has_many :page_parts
end

class PagePart < ActiveRecord::Base
  translates :body
end

class BadCls; end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  create_table :pages do |t|
    t.string :slug
  end

  create_table :page_parts do |t|
    t.integer :page_id
  end

  create_table :users do |t|
    t.string :username
    t.string :email
  end

  create_table :posts do |t|
  end

  Post.create_translation_table!({
    title: :string
  })

  Page.create_translation_table!({
    title: :string
  })

  PagePart.create_translation_table!({
    body: :text
  })
end


describe Refinery::SearchableRecord do
  before do
    User.class_eval do
      extend Refinery::SearchableRecord
      acts_like_searchable :username, :email
    end

    Post.class_eval do
      extend Refinery::SearchableRecord
      acts_like_searchable :slug, localized: [:title]
    end

    Page.class_eval do
      extend Refinery::SearchableRecord

      def self.search_by_body str
        joins(page_parts: :translations).
        where( PagePart.translation_class.arel_table[:body].matches(str) )
      end

      acts_like_searchable :slug, localized: [:title], nested: [:body]
    end
  end

  context 'simple searchable attributes' do

    it 'responds to search_by.. methods' do
      expect( User ).to respond_to(:search_by, :search_by_username, :search_by_email)
    end

    describe 'search_by' do
      it 'returns ActiveRecord::Relation' do
        expect( User.search_by nil ).to be_kind_of(ActiveRecord::Relation)
        expect( User.search_by 'test' ).to be_kind_of(ActiveRecord::Relation)
      end

      context 'invalid params' do
        it 'make impossible where' do
          # empty string
          expect( User.search_by('').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE (1 = 2)')

          # too short string
          expect( User.search_by('a').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE (1 = 2)')

          # nil and more complex query
          expect( User.where(id: 1).search_by(nil).order(id: :desc).to_sql ).to eq('SELECT "users".* FROM "users"  WHERE "users"."id" = 1 AND (1 = 2)  ORDER BY "users"."id" DESC')

          # not existing searchable attribute
          expect( User.search_by('test', 'not_existing_attr').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE (1 = 2)')
        end
      end

      context 'valid params' do
        it 'include like clause to sql' do
          # default search column
          expect( User.search_by('lorem').to_sql ).to eq('SELECT "users".* FROM "users"  WHERE ("users"."username" LIKE \'lorem%\')')

          # with custom specified search column
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

  context 'localized searchable attributes' do
    it 'responds to search_by.. methods' do
      expect( Post ).to respond_to(:search_by, :search_by_slug, :search_by_title)
    end

    describe 'search' do
      it 'returns ActiveRecord::Relation' do
        expect( Post.search_by nil ).to be_kind_of(ActiveRecord::Relation)
        expect( Post.search_by 'test' ).to be_kind_of(ActiveRecord::Relation)
        expect( Post.search_by 'test', 'title' ).to be_kind_of(ActiveRecord::Relation)
      end

      it 'include like clause to sql' do
        expect( Post.search_by('test', 'title').to_sql ).to eq('SELECT "posts".* FROM "posts" INNER JOIN "post_translations" ON "post_translations"."post_id" = "posts"."id" WHERE "post_translations"."locale" = \'en\' AND ("post_translations"."title" LIKE \'test%\')')
      end
    end
  end

  context 'nested searchable attributes' do
    it 'responds to search_by.. methods' do
      expect( Page ).to respond_to(:search_by, :search_by_slug, :search_by_title, :search_by_body)
    end

    describe 'search' do
      it 'returns ActiveRecord::Relation' do
        expect( Page.search_by nil, 'body').to be_kind_of(ActiveRecord::Relation)
        expect( Page.search_by 'test', 'body' ).to be_kind_of(ActiveRecord::Relation)
      end

      # this test does not make sense here but I included it here for reference
      it 'build correct sql query' do
        expect( Page.search_by('lorem', 'body').to_sql ).to eq('SELECT "pages".* FROM "pages" INNER JOIN "page_parts" ON "page_parts"."page_id" = "pages"."id" INNER JOIN "page_part_translations" ON "page_part_translations"."page_part_id" = "page_parts"."id" WHERE ("page_part_translations"."body" LIKE \'lorem%\')')
      end
    end

    describe 'missing defined search_by for nested model' do
      it 'raise NoMethodError' do
        expect{
          BadCls.class_eval do
            extend Refinery::SearchableRecord
            acts_like_searchable nested: [:body]
          end
        }.to raise_error(NoMethodError)
      end
    end
  end
end
