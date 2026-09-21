const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "../../replicator"
const ct = require "@game/ReplicatedStorage/shared/components"
const carModel = require "@game/ReplicatedStorage/shared/utils/car/model"

const pair = jecs.pair
const Wildcard = jecs.Wildcard

const function system(world: jecs.World)
    const needsCar = world:query(ct.Player):without(pair(ct.Car, Wildcard)):cached()

    return function()
        for id, player in needsCar do
            const car = world:entity()
            replicator:set_networked(car)

            world:add(id, pair(ct.Car, car))
            replicator:set_relation(id, ct.Car)

            task.defer(function()
                const model = carModel.create()
                model.Name = player.Name
                model.Parent = Workspace.Cars

                model.Hitbox:SetNetworkOwner(player)

                player.ReplicationFocus = model

                world:add(car, pair(ct.CarOf, id))
                world:set(car, ct.Renderable, model)

                replicator:set_relation(car, ct.CarOf)
                replicator:set_reliable(car, ct.Renderable)
            end)
        end
    end
end

return {
    name = "players/car",
    system = system,
    phase = planck_runservice.Phases.Update,
}
