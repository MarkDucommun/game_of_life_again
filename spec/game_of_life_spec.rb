require 'spec_helper'
require_relative '../game_of_life'

describe 'Game of Life' do
  # 3 - x x - -     - x x - - 3
  # 2 - x - x -     - - - x - 2
  # 1 x x x - -  => - - - x - 1
  # 0 x x - - x     x - x - - 0
  #   0 1 2 3 4     0 1 2 3 4

  let(:cell_coordinates) {
    [
      {x:0, y:0},
      {x:0, y:1},
      {x:1, y:0},
      {x:1, y:1},
      {x:1, y:2},
      {x:1, y:3},
      {x:2, y:1},
      {x:2, y:3},
      {x:3, y:2},
      {x:4, y:0}
    ]
  }

  let(:world) { World.new(cell_coordinates) }

  describe World do
    it 'has a plane on which cells exist' do
      expect(world.plane).to be_a Hash
    end

    it 'has cells at particular sets of cooridinates on the plane' do
      expect(world.get(x:0, y:0)).to be true
    end

    it 'can create a live cell at a particular set of coordinates' do
      world.set(true, x:0, y:3)
      expect(world.get(x:0, y:3)).to be true
    end

    it 'can tell if a cell has been touched' do
      untouched = World.new
      expect(untouched.untouched?(x:0, y:0)).to be true
      untouched.set(false, x:0, y: 0)
      expect(untouched.untouched?(x:0, y:0)).to be false
    end

    it 'can tell if a cell is alive' do
      expect(world.alive?(x:0, y:0)).to be true
    end

    it 'can tell if a cell is dead' do
      expect(world.dead?(x:2, y:0)).to be true
    end

    it 'can create a world using a list of coordinates of live cells' do
      expect(world.get(x:0, y:0)).to be true
      expect(world.get(x:1, y:1)).to be true
      expect(world.get(x:0, y:3)).to be_nil
    end

    it 'can locate all of a cells neighbors' do
      # Cell at x:1, y:1
      cell_neighbors = [
        {x:1, y:2},  # top
        {x:2, y:2},  # top-right
        {x:2, y:1},  # right
        {x:2, y:0},  # bottom-right
        {x:1, y:0},  # bottom
        {x:0, y:0},  # bottom-left
        {x:0, y:1},  # left
        {x:0, y:2},  # top-left
      ]
      expect(World.neighbors(x:1, y:1)).to eq cell_neighbors
    end

    it 'can count how many neighbors are alive' do
      expect(world.living_neighbors(x:0, y:0)).to be 3
      expect(world.living_neighbors(x:1, y:1)).to be 5
    end

    it 'can add one coordinate to another' do
      a = {x:1, y:1}
      b = {x:2, y:2}
      expected = {x:3, y:3}
      expect(World.add(a, b)).to eq expected
    end

    context 'cell is alive' do
      it 'knows the cell should survive if it has two neighbors' do
        expect(world.survives?(x:1, y:3)).to be true
      end

      it 'knows the cell should survive if it has three neighbors' do
        expect(world.survives?(x:0, y:0)).to be true
      end

      it 'knows the cell should die if it has fewer than two neighbors' do
        expect(world.survives?(x:4, y:0)).to be false
      end

      it 'knows the cell should die if it has more than three neighbors' do
        expect(world.survives?(x:1, y:1)).to be false
      end
    end

    context 'cell is dead' do
      it 'knows the cell should come to life if it has three neighbors' do
        expect(world.survives?(x:2, y:0)).to be true
      end

      it 'knows the cell should stay dead with two or fewer neighbors' do
        expect(world.survives?(x:4, y:3)).to be false
      end

      it 'knows the cell should stay dead with four or more neighbors' do
        expect(world.survives?(x:2, y:2)).to be false
      end
    end
  end

  describe SpaceTime do
    let(:space_time) { SpaceTime.new(world) }

    it 'has a present world' do
      expect(space_time.present_world).to be_a World
    end

    it 'has a future world' do
      expect(space_time.future_world).to be_a World
    end

    it 'can update the future world to reflect the cells that should survive next tic based on the status of the present world' do
      future_coordinates = [
          {x:0, y:0},
          {x:1, y:3},
          {x:2, y:0},
          {x:2, y:3},
          {x:3, y:1},
          {x:3, y:2}
        ]
      future_world = World.new(future_coordinates)
      space_time.update_the_future
      expect(space_time.future_world.plane).to eq future_world.plane
    end

    it 'can check the status of a cell and its eight neighbors when updating the future world' do
      empty = SpaceTime.new(World.new)
      expected_plane = {
        {x:1, y:1} => false,
        {x:1, y:2} => false,
        {x:2, y:2} => false,
        {x:2, y:1} => false,
        {x:2, y:0} => false,
        {x:1, y:0} => false,
        {x:0, y:0} => false,
        {x:0, y:1} => false,
        {x:0, y:2} => false
      }
      empty.update_cell({x:1, y:1})
      expect(empty.future_world.plane).to eq expected_plane
    end

    it 'can cleanup all dead cells from a world' do
      empty = SpaceTime.new(World.new)
      empty.update_cell({x: 1, y:1})
      empty.future_world.cleanup
      expect(empty.future_world.plane).to eq Hash.new
    end

    it 'can move forwards' do
      old_future = space_time.future_world
      expect(space_time.present_world.plane).to_not eq old_future.plane
      space_time.tic!
      expect(space_time.present_world.plane).to eq old_future.plane
    end
  end
end
