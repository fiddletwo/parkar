const Workspace = game:GetService "Workspace"

const jecs = require "@game/ReplicatedStorage/packages/jecs"
const planck_runservice = require "@game/ReplicatedStorage/packages/planck-runservice"
const replicator = require "../../replicator"
const ct = require "@game/ReplicatedStorage/shared/components"
const presets = require "@game/ReplicatedStorage/shared/presets/car"
const carModel = require "@game/ReplicatedStorage/shared/utils/car/model"

const pair = jecs.pair
const Wildcard = jecs.Wildcard
const ChildOf = jecs.ChildOf

const function system(world: jecs.World)
    const needsCar = world:query(ct.Player):without(pair(ct.Car, Wildcard)):cached()

    return function()
        for id, player in needsCar do
            const car = world:entity()
            replicator:set_networked(car)

            world:add(id, pair(ct.Car, car))
            replicator:set_relation(id, ct.Car)

            task.defer(function()
                const preset = presets.default

                const model = carModel.create(preset)
                model.Name = player.Name
                model.Parent = Workspace.Cars

                model.Hitbox:SetNetworkOwner(player)

                player.ReplicationFocus = model

                world:add(car, pair(ct.CarOf, id))
                world:set(car, ct.Renderable, model)
                world:set(car, ct.CarPreset, "default")

                replicator:set_relation(car, ct.CarOf)
                replicator:set_reliable(car, ct.Renderable)
                replicator:set_reliable(car, ct.CarPreset)

                for name, position in preset.wheels :: { [string]: Vector3 } do
                    const wheel = world:entity()
                    replicator:set_networked(wheel)

                    world:set(wheel, ct.Name, name)
                    world:add(wheel, ct.Wheel)
                    world:add(wheel, pair(ChildOf, car))
                    world:set(wheel, ct.WheelSpring, preset.spring)
                    world:set(wheel, ct.Position, position)
                    world:set(wheel, ct.Length, preset.spring.rest)

                    replicator:set_reliable(wheel, ct.Name)
                    replicator:set_reliable(wheel, ct.Wheel)
                    replicator:set_relation(wheel, ChildOf)
                    replicator:set_reliable(wheel, ct.WheelSpring)
                    replicator:set_reliable(wheel, ct.Position)
                    replicator:set_once(wheel, ct.Length)
                end
            end)
        end
    end
end

return {
    name = "players/car",
    system = system,
    phase = planck_runservice.Phases.Update,
}
