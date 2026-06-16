class MemoryPolicy < ApplicationPolicy
  def show?    = owner?
  def create?  = true
  def update?  = owner?
  def destroy? = owner?

  private

  def owner?
    record.capsule.user_id == user.id
  end
end
