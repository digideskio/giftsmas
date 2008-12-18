class Gift < Sequel::Model
  @scaffold_fields = [:name]
  @scaffold_associations = [:receivers, :senders]
  @scaffold_session_value = :event_id
  many_to_many :senders, :class=>:Person, :join_table=>:gift_senders, :right_key=>:person_id, :order=>:name
  many_to_many :receivers, :class=>:Person, :join_table=>:gift_receivers, :right_key=>:person_id, :order=>:name

  def self.add(event, gift_name, senders, receivers, new_senders, new_receivers)
    user = event.user
    gift_senders = senders.map{|i| Person.for_user_by_id(user, i)}
    gift_receivers = receivers.map{|i| Person.for_user_by_id(user, i)}
    db.transaction do
      gift_senders += new_senders.map do |name|
        Person.for_user_by_name(user, name).make_sender(event)
      end
      gift_receivers += new_receivers.map do |name|
        Person.for_user_by_name(user, name).make_receiver(event)
      end
      gift_senders = gift_senders.compact.uniq
      gift_receivers = gift_receivers.compact.uniq
      if gift_senders.length > 0 and gift_receivers.length > 0
        gift = create(:event_id=>event.id, :name=>gift_name)
        gift_senders.each{|s| gift.add_sender(s)}
        gift_receivers.each{|s| gift.add_receiver(s)}
        gift
      end
    end
  end
end
