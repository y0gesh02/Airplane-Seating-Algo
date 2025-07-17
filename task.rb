# Seat class representing individual seats
class Seat
  attr_accessor :type, :passenger, :assigned

  TYPE = { WINDOW: 'W', MIDDLE: 'M', AISLE: 'A' }.freeze

  def initialize(type = nil)
    @type = type
    @passenger = nil
    @assigned = false
  end

  def can_be_assigned?(seat_type)
    return false if @assigned
    @type == seat_type
  end

  def assign(seat_type, passenger_id, _priority = nil)
    @passenger = passenger_id
    @assigned = true
  end
end

# Block class representing a 2D block of seats
class Block
  attr_reader :col, :rows

  def initialize(col, rows, is_first_col, is_last_col)
    @col = col
    @rows = rows
    @seats_2d = Array.new(rows) { Array.new(col) { Seat.new } }
    assign_seat_types(is_first_col, is_last_col)
  end

  def assign_seat_types(is_first_col, is_last_col)
    @seats_2d.each do |row|
      row.each_with_index do |seat, index|
        seat.type =
          if row.length == 1
            Seat::TYPE[:WINDOW]
          elsif index == 0
            is_first_col ? Seat::TYPE[:WINDOW] : Seat::TYPE[:AISLE]
          elsif index == row.length - 1
            is_last_col ? Seat::TYPE[:WINDOW] : Seat::TYPE[:AISLE]
          else
            Seat::TYPE[:MIDDLE]
          end
      end
    end
  end

  def row_at(index)
    @seats_2d[index] || []
  end
end

# RowBlock class a single block viewed at a specific row index
class RowBlock
  def initialize(block, row_index)
    @block = block
    @row_index = row_index
  end

  def seats
    @block.row_at(@row_index)
  end
end

# Row class horizontal row across the entire airplane
class Row
  attr_reader :blocks, :row_index

  def initialize(blocks, row_index)
    @blocks = blocks.map { |block| RowBlock.new(block, row_index) }
    @row_index = row_index
  end
end

# Airplane class for creating the seat structure and allocating seat
class Airplane
  attr_reader :rows, :blocks
  
  SEAT_PRIORITIES = [Seat::TYPE[:AISLE], Seat::TYPE[:WINDOW], Seat::TYPE[:MIDDLE]].freeze

  def initialize(input)
    @blocks = input.each_with_index.map do |(cols, rows), i|
      Block.new(cols, rows, i == 0, i == (input.size - 1))
    end
    @max_rows = @blocks.map(&:rows).max
    @rows = (0...@max_rows).map { |row_index| Row.new(@blocks, row_index) }
  end

  def self.create(input)
    new(input)
  end

  def assign_passengers(count)
    passenger_ids = (1..count).to_a
    assigned = 0

    SEAT_PRIORITIES.each do |seat_type|
      break if assigned >= count
      (0...@max_rows).each do |row_index|
        break if assigned >= count
        @blocks.each do |block|
          break if assigned >= count
          next if row_index >= block.rows
          block.row_at(row_index).each do |seat|
            if seat.can_be_assigned?(seat_type)
              seat.assign(seat_type, passenger_ids[assigned])
              assigned += 1
            end
            break if assigned >= count
          end
        end
      end
    end
  end
end