
type Todo.t = {
    string id,
    string title,
    bool completed
}

database todomvc {    
    Todo.t /todos[{id}]
    /todos[_]/completed = false
}

module Model {

}
