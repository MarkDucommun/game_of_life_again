class SpaceTime
  attr_accessor :present_world, :future_world

  def initialize(starting_world)
    self.present_world = starting_world
    self.future_world = World.new
  end

  def tic!
    update_the_future
    self.present_world = future_world
    self.future_world = World.new
  end

  def update_the_future
    present_world.plane.each do |coordinates, value|
      update_cell(coordinates)
    end
    future_world.cleanup
  end

  def update_cell(coordinates)
    if future_world.untouched?(coordinates)
      future_world.set(present_world.survives?(coordinates), coordinates)
    end

    World.neighbors(coordinates).each do |n_coordinates|
      if future_world.untouched?(n_coordinates)
        alive = present_world.survives?(n_coordinates)
        future_world.set(alive, n_coordinates)
      end
    end
  end
end

class World
  attr_accessor :plane

  def initialize(cell_coordinates = [])
    self.plane = {}
    cell_coordinates.each { |coordinate| set(true, coordinate) }
  end

  def get(coordinates)
    plane[coordinates]
  end

  def set(alive, coordinates)
    plane[coordinates] = alive
  end

  def untouched?(coordinates)
    get(coordinates).nil?
  end

  def alive?(coordinates)
    !!get(coordinates)
  end

  def dead?(coordinates)
    !get(coordinates)
  end

  def survives?(coordinates)
    alive_neighbors = living_neighbors(coordinates)
    return true if alive?(coordinates) && alive_neighbors == 2 || alive_neighbors == 3
    return true if dead?(coordinates) && alive_neighbors == 3
    false
  end

  def living_neighbors(coordinates)
    World.neighbors(coordinates).select { |n_coordinates| get(n_coordinates) }.length
  end

  def cleanup
    plane.each do |coordinates, value|
     plane.delete(coordinates) unless alive?(coordinates)
    end
  end

  def self.neighbors(coordinates)
    neighbor_transformations.map do |transformation|
      add(coordinates, transformation)
    end
  end

  def self.add(a, b)
    result = {}
    a.each { |axis, value| result[axis] = a[axis] + b[axis] }
    result
  end

  def self.neighbor_transformations
    [
      {x:0,  y:1},   # top
      {x:1,  y:1},   # top-right
      {x:1,  y:0},   # right
      {x:1,  y:-1},  # bottom-right
      {x:0,  y:-1},  # bottom
      {x:-1, y:-1},  # bottom-left
      {x:-1, y:0},   # left,
      {x:-1, y:1},   # top-left
    ]
  end
end
