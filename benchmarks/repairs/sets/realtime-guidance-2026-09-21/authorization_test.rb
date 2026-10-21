# frozen_string_literal: true

class ReactionRepairAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:kevin)
    @comment = comments(:logo_agreement_jz)
  end

  test 'a forged ID never deletes the callers own reaction' do
    own = @comment.reactions.create!(creator: users(:kevin), content: 'mine')
    other = @comment.reactions.create!(creator: users(:david), content: 'theirs')
    assert_no_difference('Reaction.count') do
      delete card_comment_reaction_path(@comment.card, @comment, other), as: :turbo_stream
    end
    assert_response :forbidden
    assert Reaction.exists?(own.id)
    assert Reaction.exists?(other.id)
  end

  test 'a reaction from another comment is not found and neither record changes' do
    own = @comment.reactions.create!(creator: users(:kevin), content: 'mine')
    other_comment = comments(:logo_agreement_kevin)
    other = other_comment.reactions.create!(creator: users(:kevin), content: 'elsewhere')
    assert_no_difference('Reaction.count') do
      delete card_comment_reaction_path(@comment.card, @comment, other), as: :turbo_stream
    end
    assert_response :not_found
    assert Reaction.exists?(own.id)
    assert Reaction.exists?(other.id)
  end

  test 'a missing reaction ID never falls back to an owned record' do
    own = @comment.reactions.create!(creator: users(:kevin), content: 'mine')
    assert_no_difference('Reaction.count') do
      delete card_comment_reaction_path(@comment.card, @comment, 'missing'), as: :turbo_stream
    end
    assert_response :not_found
    assert Reaction.exists?(own.id)
  end

  test 'a comment cannot be addressed through another card' do
    assert_no_difference('Reaction.count') do
      post card_comment_reactions_path(cards(:layout), @comment), params: { reaction: { content: 'wrong' } },
                                                                  as: :turbo_stream
    end
    assert_response :not_found
  end

  test 'an inaccessible card cannot receive or lose reactions' do
    card, comment = Current.with(account: @comment.account, user: users(:kevin)) do
      private_card = boards(:private).cards.create!(title: 'Private', creator: users(:kevin), status: :published)
      [private_card, private_card.comments.create!(body: 'Private comment', creator: users(:kevin))]
    end
    reaction = comment.reactions.create!(content: 'private', creator: users(:kevin))
    logout_and_sign_in_as users(:jz)
    refute users(:jz).accessible_cards.exists?(card.id)
    assert_no_difference('Reaction.count') do
      post card_comment_reactions_path(card, comment), params: { reaction: { content: 'wrong' } }, as: :turbo_stream
      assert_response :not_found
      delete card_comment_reaction_path(card, comment, reaction), as: :turbo_stream
      assert_response :not_found
    end
    assert Reaction.exists?(reaction.id)
  end

  test 'invalid content persists nothing and reports validation errors' do
    ['', 'x' * 17].each do |content|
      assert_no_difference('Reaction.count') do
        post card_comment_reactions_path(@comment.card, @comment), params: { reaction: { content: content } },
                                                                   as: :turbo_stream
      end
      assert_response :unprocessable_entity
      assert_includes response.body, 'Content'
    end
  end
end
