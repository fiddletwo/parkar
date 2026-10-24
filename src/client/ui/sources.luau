const vide = require "@game/ReplicatedStorage/packages/vide"

const source = vide.source

return {
    car = {
        alive = source(false),
        boost = source(100),
    },
    game = {
        countdown = source(0),
        round = source(0),
    },
}
