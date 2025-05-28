defmodule Myhp.Repo.Migrations.CheckAdminUser do
  use Ecto.Migration
  
  def up do
    # Set admin@markcotner.com as admin
    execute """
    UPDATE users 
    SET admin = true 
    WHERE email = 'admin@markcotner.com'
    """
  end
  
  def down do
    # Remove admin privileges from admin@markcotner.com
    execute """
    UPDATE users 
    SET admin = false 
    WHERE email = 'admin@markcotner.com'
    """
  end
end