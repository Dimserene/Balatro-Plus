local e = {
  loc_txt = {
    name = "Framed Card",
    text = {
      "Gain {C:chips}+#1#{} Chips",
      "each {C:attention}triggered",
    },
  },
  config = { extra = 1 },
  atlas = 2,
}

function e:loc_vars(_, card)
  return { vars = { card.ability.extra } }
end

function e:calculate(card, ctx, _)
  if ctx.cardarea == G.play and not ctx.repetition then
    card.ability.perma_bonus = card.ability.perma_bonus + card.ability.extra
  end
end

return e
