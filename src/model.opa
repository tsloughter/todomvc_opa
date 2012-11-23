
type Todo.t = {
    string id,
    string useref,
    string value,
    bool done,
    string created_at
}

database todomvc {    
    Todo.t /todos[{id}]
    /todos[_]/done = false
}

module Model {

}
