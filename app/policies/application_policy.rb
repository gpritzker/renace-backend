class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "Usuario no autenticado" unless user
    @user = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def update?  = false
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class}#resolve no implementado"
    end

    private

    attr_reader :user, :scope
  end
end
