# frozen_string_literal: true

class ReactionRepairAuthorizationTest < ActionDispatch::IntegrationTest
  test 'a forged deletion is rejected and leaves the reaction intact' do
    sign_in_as users(:kevin)
    reaction = comments(:logo_agreement_jz).reactions.create!(creator: users(:david), content: 'owned')
    assert_no_difference('Reaction.count') do
      delete card_comment_reaction_path(reaction.comment.card, reaction.comment, reaction), as: :turbo_stream
    end
    assert_response :forbidden
  end

  test 'a comment from another card cannot be addressed through the visible card' do
    sign_in_as users(:kevin)
    comment = Comment.where.not(card_id: cards(:logo).id).first!
    assert_no_difference('Reaction.count') do
      post card_comment_reactions_path(cards(:logo), comment), params: { reaction: { content: 'wrong' } },
                                                               as: :turbo_stream
    end
    assert_response :not_found
  end
end
