#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

shared_examples_for "it is relayable" do
  describe "interacted_at" do
    it "sets the interacted at of the parent to the created at of the relayable post" do
      Timecop.freeze Time.now do
        relayable.save
        if relayable.parent.respond_to?(:interacted_at) #I'm sorry.
          expect(relayable.parent.interacted_at.to_i).to eq(relayable.created_at.to_i)
        end
      end
    end
  end

  describe "validations" do
    context "author ignored by parent author" do
      context "the author is on the parent object author's ignore list when object is created" do
        before do
          bob.blocks.create(person: alice.person)
        end

        it "is invalid" do
          expect(relayable).not_to be_valid
          expect(relayable.errors[:author_id].size).to eq(1)
        end

        it "works if the object has no parent" do # This can happen if we get a comment for a post that's been deleted
          relayable.parent = nil
          expect { relayable.valid? }.to_not raise_exception
        end
      end

      context "the author is added to the parent object author's ignore list later" do
        it "is valid" do
          relayable.save!
          bob.blocks.create(person: alice.person)
          expect(relayable).to be_valid
        end
      end
    end
  end

  describe "#subscribers" do
    it "returns the parents original audience, if the parent is local" do
      expect(object_on_local_parent.subscribers.map(&:id))
        .to match_array([local_leia.person, remote_raphael].map(&:id))
    end

    it "returns remote persons of the parents original audience, if the parent is local, but the author is remote" do
      expect(remote_object_on_local_parent.subscribers.map(&:id)).to match_array([remote_raphael].map(&:id))
    end

    it "returns the author of parent and author of relayable (for local delivery), if the parent is not local" do
      expect(object_on_remote_parent.subscribers.map(&:id))
        .to match_array([remote_raphael, local_luke.person].map(&:id))
    end
  end
end
