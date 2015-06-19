EncomDbs::Application.routes.draw do

  get 'querycache/users' => 'querycache#users', as: 'querycache'

end
