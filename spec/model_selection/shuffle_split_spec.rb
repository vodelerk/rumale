# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rumale::ModelSelection::ShuffleSplit do
  let(:n_splits) { 3 }
  let(:n_samples) { 10 }
  let(:n_features) { 3 }
  let(:test_size) { 0.2 }
  let(:train_size) { 0.6 }
  let(:n_test_samples) { (n_samples * test_size).to_i }
  let(:n_train_samples) { (n_samples * train_size).to_i }
  let(:samples) { Numo::DFloat.new(n_samples, n_features).rand }
  let(:labels) { nil }

  it 'splits the dataset with given test and train sizes.' do
    splitter = described_class.new(n_splits: n_splits, test_size: test_size, train_size: train_size, random_seed: 1)
    validation_ids = splitter.split(samples, labels)
    expect(splitter.n_splits).to eq(n_splits)
    expect(validation_ids.class).to eq(Array)
    expect(validation_ids.size).to eq(n_splits)
    expect(validation_ids[0].size).to eq(2)
    expect(validation_ids[0][0].size).to eq(n_train_samples)
    expect(validation_ids[0][1].size).to eq(n_test_samples)
    expect(validation_ids[1][0].size).to eq(n_train_samples)
    expect(validation_ids[1][1].size).to eq(n_test_samples)
    expect(validation_ids[2][0].size).to eq(n_train_samples)
    expect(validation_ids[2][1].size).to eq(n_test_samples)
    expect(validation_ids[0][0]).not_to match_array([0, 1, 2, 3, 4, 5])
    expect(validation_ids[0][1]).not_to match_array([0, 1])
    expect(validation_ids[1][0]).not_to match_array([0, 1, 2, 3, 4, 5])
    expect(validation_ids[1][1]).not_to match_array([0, 1])
    expect(validation_ids[2][0]).not_to match_array([0, 1, 2, 3, 4, 5])
    expect(validation_ids[2][1]).not_to match_array([0, 1])
  end

  it 'splits the dataset with given test size.' do
    splitter = described_class.new(n_splits: n_splits, random_seed: 1)
    validation_ids = splitter.split(samples, labels)
    expect(splitter.n_splits).to eq(n_splits)
    expect(validation_ids.class).to eq(Array)
    expect(validation_ids.size).to eq(n_splits)
    expect(validation_ids[0].size).to eq(2)
    expect(validation_ids[0][0].size).to eq(9)
    expect(validation_ids[0][1].size).to eq(1)
    expect(validation_ids[0][0]).not_to match_array([3, 4, 5, 6, 7, 8])
    expect(validation_ids[0][1]).not_to match_array([0, 1, 2])
  end

  it 'raises ArgumentError given a wrong split number.' do
    # exceeding the number of samples
    splitter = described_class.new(n_splits: n_samples + 10)
    expect { splitter.split(samples, labels) }.to raise_error(ArgumentError)
    # less than 1
    splitter = described_class.new(n_splits: 0)
    expect { splitter.split(samples, labels) }.to raise_error(ArgumentError)
  end

  it 'raises RangeError given wrong sample sizes.' do
    splitter = described_class.new(n_splits: 1, test_size: 1.1)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
    splitter = described_class.new(n_splits: 1, test_size: 0.01)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
    splitter = described_class.new(n_splits: 1, test_size: 0.0)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
    splitter = described_class.new(n_splits: 1, train_size: 1.1)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
    splitter = described_class.new(n_splits: 1, train_size: 0.01)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
    splitter = described_class.new(n_splits: 1, train_size: 0.0)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
    splitter = described_class.new(n_splits: 1, test_size: 0.1, train_size: 0.9)
    expect { splitter.split(samples, labels) }.not_to raise_error
    splitter = described_class.new(n_splits: 1, test_size: 0.2, train_size: 0.9)
    expect { splitter.split(samples, labels) }.to raise_error(RangeError)
  end
end
