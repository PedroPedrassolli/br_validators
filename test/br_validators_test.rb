# frozen_string_literal: true

require "test_helper"

describe BrValidators do
  subject { BrValidators::VERSION }

  describe "VERSION" do
    it "segue o versionamento semântico (MAIOR.MENOR.CORREÇÃO)" do
      assert_match(/\A\d+\.\d+\.\d+\z/, subject)
    end
  end
end
