# frozen_string_literal: true

require_relative '../../../test_helper'

class AssertMatchTest < Minitest::Test
  %i[match match? =~].each do |matcher|
    define_method("test_registers_offense_when_using_assert_with_#{matcher}") do
      assert_offense(<<~RUBY, matcher: matcher)
        class FooTest < Minitest::Test
          def test_do_something
            assert(matcher.#{matcher}(object))
            ^^^^^^^^^^^^^^^^{matcher}^^^^^^^^^ Prefer using `assert_match(matcher, object)`.
          end
        end
      RUBY

      assert_correction(<<~RUBY)
        class FooTest < Minitest::Test
          def test_do_something
            assert_match(matcher, object)
          end
        end
      RUBY
    end

    define_method("test_registers_offense_when_using_assert_with_#{matcher}_and_lhs_is_regexp_literal") do
      assert_offense(<<~RUBY, matcher: matcher)
        class FooTest < Minitest::Test
          def test_do_something
            assert(/regexp/.#{matcher}(object))
            ^^^^^^^^^^^^^^^^^{matcher}^^^^^^^^^ Prefer using `assert_match(/regexp/, object)`.
          end
        end
      RUBY

      assert_correction(<<~RUBY)
        class FooTest < Minitest::Test
          def test_do_something
            assert_match(/regexp/, object)
          end
        end
      RUBY
    end

    define_method("test_registers_offense_when_using_assert_with_#{matcher}_and_rhs_is_regexp_literal") do
      assert_offense(<<~RUBY, matcher: matcher)
        class FooTest < Minitest::Test
          def test_do_something
            assert(object.#{matcher}(/regexp/))
            ^^^^^^^^^^^^^^^{matcher}^^^^^^^^^^^ Prefer using `assert_match(/regexp/, object)`.
          end
        end
      RUBY

      assert_correction(<<~RUBY)
        class FooTest < Minitest::Test
          def test_do_something
            assert_match(/regexp/, object)
          end
        end
      RUBY
    end

    define_method("test_registers_offense_when_using_assert_with_#{matcher}_and_message") do
      assert_offense(<<~RUBY, @cop, matcher: matcher)
        class FooTest < Minitest::Test
          def test_do_something
            assert(matcher.#{matcher}(object), 'message')
            ^^^^^^^^^^^^^^^^{matcher}^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_match(matcher, object, 'message')`.
          end
        end
      RUBY

      assert_correction(<<~RUBY)
        class FooTest < Minitest::Test
          def test_do_something
            assert_match(matcher, object, 'message')
          end
        end
      RUBY
    end

    define_method("test_registers_offense_when_using_assert_with_#{matcher}_and_heredoc_message") do
      assert_offense(<<~RUBY, matcher: matcher)
        class FooTest < Minitest::Test
          def test_do_something
            assert(matcher.#{matcher}(object), <<~MESSAGE
            ^^^^^^^^^^^^^^^^{matcher}^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_match(matcher, object, <<~MESSAGE)`.
              message
            MESSAGE
            )
          end
        end
      RUBY

      assert_correction(<<~RUBY)
        class FooTest < Minitest::Test
          def test_do_something
            assert_match(matcher, object, <<~MESSAGE
              message
            MESSAGE
            )
          end
        end
      RUBY
    end

    define_method("test_registers_offense_when_using_assert_with_#{matcher}_in_redundant_parentheses") do
      assert_offense(<<~RUBY, matcher: matcher)
        class FooTest < Minitest::Test
          def test_do_something
            assert((matcher.#{matcher}(string)))
            ^^^^^^^^^^^^^^^^^{matcher}^^^^^^^^^^ Prefer using `assert_match(matcher, string)`.
          end
        end
      RUBY

      assert_correction(<<~RUBY)
        class FooTest < Minitest::Test
          def test_do_something
            assert_match((matcher, string))
          end
        end
      RUBY
    end
  end

  def test_does_not_register_offense_when_using_assert_match
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_match(matcher, object)
        end
      end
    RUBY
  end

  def test_does_not_register_offense_when_using_assert_with_no_arguments_match_call
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert(matcher.match)
        end
      end
    RUBY
  end

  def test_does_not_register_offense_when_using_assert_with_no_arguments_match_safe_navigation_call
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert(matcher&.match)
        end
      end
    RUBY
  end
end
