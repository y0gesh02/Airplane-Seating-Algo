require 'rspec'

load 'task.rb'

RSpec.describe "Airplane" do

	describe "check seat_type" do
		let(:airplane) { Airplane.create(input)}
		let(:blocks) { airplane.rows[0].blocks }
		context "for multiple blocks" do
			let(:input) {[[3,3],[3,3],[3,3]]}
			it "should be matched" do
				expect(blocks[0].seats.map(&:type)).to contain_exactly(Seat::TYPE[:WINDOW], Seat::TYPE[:MIDDLE], Seat::TYPE[:AISLE])
				expect(blocks[1].seats.map(&:type)).to contain_exactly(Seat::TYPE[:AISLE], Seat::TYPE[:MIDDLE], Seat::TYPE[:AISLE])
				expect(blocks.last.seats.map(&:type)).to contain_exactly(Seat::TYPE[:AISLE], Seat::TYPE[:MIDDLE], Seat::TYPE[:WINDOW])
			end
		end
		context "for single block" do
			let(:input) {[[3,3]]}
			it "should be matched" do
				expect(blocks[0].seats.map(&:type)).to contain_exactly(Seat::TYPE[:WINDOW], Seat::TYPE[:MIDDLE], Seat::TYPE[:WINDOW])
			end
		end
	end

	describe "assign_seat" do
		let(:airplane) { Airplane.create([[3,3],[3,3],[3,3]])}
		let(:seat) { airplane.rows[0].blocks[0].seats[0] }
		subject(:assignable) { seat.can_be_assigned?(Seat::TYPE[:WINDOW]) }
		context "when assigning window seat" do
			it "should get assigned" do
				is_expected.to eq true 
			end
		end	
		context "when seat is already reserved" do
			let!(:assign_seat) { seat.assign(Seat::TYPE[:WINDOW], 10, 5) }
			it "should not get assigned" do
				is_expected.to eq false 
			end
		end	
	end

	describe "seat_assign_rule" do
		let(:airplane) { Airplane.create(input)}
		let!(:assign_passengers) { airplane.assign_passengers(10) }
		let(:seats) { airplane.rows[0].blocks[0].seats }
		context "seat type preference" do
			let(:input) {[[3,1]]}
			it "should be matched" do
				expect(seats.map(&:passenger)).to contain_exactly(2, 3, 1)
			end
		end	
		context "left to right order" do
			let(:input) {[[4,1]]}
			it "should be matched" do
				expect(seats.map(&:passenger)).to contain_exactly(1, 3, 4, 2)
			end
		end
		context "up to down order" do
			let(:input) {[[1,3]]}
			let(:rows) { airplane.rows }
			it "should be matched" do
				expect(rows[0].blocks[0].seats.map(&:passenger)).to contain_exactly(1)
				expect(rows[1].blocks[0].seats.map(&:passenger)).to contain_exactly(2)
				expect(rows.last.blocks[0].seats.map(&:passenger)).to contain_exactly(3)
			end
		end
	end
end
