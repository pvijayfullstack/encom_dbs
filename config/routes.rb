EncomDbs::Application.routes.draw do

  match 'querycache/users' => 'querycache#users', as: 'querycache'

end
