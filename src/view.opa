module View {

    // View code goes here

    function update_counts() {
        num_completed = Dom.length(Dom.select_class("completed"));
        total = Dom.length(Dom.select_class("todo"));
        Dom.set_text(#number_completed, Int.to_string(num_completed));
        Dom.set_text(#number_left, Int.to_string(total - num_completed))
    }

    function make_completed(string id) {
        if(Dom.is_checked(Dom.select_inside(#{id}, Dom.select_raw_unsafe("input")))) {
            db_make_completed(id);
            Dom.add_class(#{id}, "completed")
        } else {
            Dom.remove_class(#{id}, "completed")
        };
        update_counts()
    }

    exposed @async function db_make_completed(string id) {
        /todomvc/todos[~{ id }] <- { completed : true };
    }

    function remove_item(string id) {
        db_remove_item(id);
        Dom.remove(Dom.select_parent_one(#{id}));
        update_counts()
    }

    exposed @async function db_remove_item(string id) {
        Db.remove(@/todomvc/todos[~{ id }]);
        void
    }

    @async function remove_all_completed() {
        Dom.iter((function(x){remove_item(Dom.get_id(x))}),
                  Dom.select_class("completed"))
    }    

    @async function mark_all_completed() {
        Dom.iter((function(x){make_completed(Dom.get_id(x))}),
                  Dom.select_class("todo"))
    }    

    function update_todo(string id, string title) {
        db_add_todo(id, title);
        update_todo_on_page(id, title);
        Dom.void_style(#{id^"_destroy"});
    }

    function update_todo_on_page(string id, string title) {
        line = <label id={id^"_todo"} class="todo_content" onclick={function(_){make_editable(id, title)}}>{ title }</label>
        _ = Dom.put_replace(#{id^"_input"}, Dom.of_xhtml(line));
        void
    }

    function make_editable(string id, string title) {
        line = <input id={id^"_input"} class="xlarge todo_content" onnewline={function(_){update_todo(id, Dom.get_value(#{id^"_input"}))}} title={ title } />
        Dom.show(#{id^"_destroy"});
        _ = Dom.put_replace(#{id^"_todo"}, Dom.of_xhtml(line));
        update_counts()
    }

    exposed function add_todos() {
        dbset(Todo.t, _) items = /todomvc/todos;
        it = DbSet.iterator(items);
        Iter.iter((function(item){add_todo_to_page(item.id, item.title, item.completed)}), it)
    }

    function add_todo_to_page(string id, string title, bool is_completed) {
        completed = if (is_completed) "completed" else ""
        checkbox = if (is_completed) {
                <input checked="yes" class="toggle" type="checkbox" onclick={function(_){make_completed(id)}}/>
          }else{
            <input class="toggle" type="checkbox" onclick={function(_){make_completed(id)}}/>
          }
        line =
          <li>
            <div class="todo {completed}" id={ id }>
              <div class="display">
                {checkbox}
                <label id={id^"_todo"} onclick={function(_){ if (is_completed) { }else{ make_editable(id, title) }}}>{ title }</label>
                <button id={id^"_destroy"} class="destroy" onclick={function(_){remove_item(id)}}></button>
             </div>
           </div>
          </li>
        Dom.transform([#todo_list =+ line]);
        Dom.scroll_to_bottom(#todo_list);
        Dom.set_value(#new_todo, "");
        update_counts()
    }


    exposed @async function db_add_todo(string id, string title) {
        /todomvc/todos[~{ id }] <- { id : id, title : title } // not necessary to specify default titles
    }

    function add_todo(string x) {
        
        id = Dom.fresh_id();
        db_add_todo(id, x);
        add_todo_to_page(id, x, false)
    }

    function page_template(title) {
        html =
            <section id="todoapp">
                        <header id="header">
            			<h1>todos</h1>
                                 <input id=#new_todo placeholder="What needs to be completed?" autofocus
                                  onnewline={function(_){add_todo(Dom.get_value(#new_todo))}} />
            		</header>
            		<!-- This section should be hidden by default and shown when there are todos -->
            		<section id="main">
            			<input id="toggle-all" type="checkbox">
            			<label for="toggle-all" onclick={function(_){mark_all_completed()}}>Mark all as complete</label>
                                  <div id=#todos>
                                    <ul id=#todo_list onready={function(_){add_todos()}} class="unstyled"></ul>
                                  </div>
                      		</section>
	    <!-- This footer should hidden by default and shown when there are todos -->
	    <footer id="footer">
            			<!-- This should be `0 items left` by default -->
            			<span id="todo-count"><span id=#number_left class="number bold">0</span> item left</span>
            			<!-- Remove this if you don't implement routing 
            			<ul id="filters">
            				<li>
            					<a class="selected" href="#/">All</a>
            				</li>
            				<li>
            					<a href="#/active">Active</a>
            				</li>
            				<li>
            					<a href="#/completed">Completed</a>
            				</li>
            			</ul> -->
            			<button id="clear-completed" onclick={function(_){remove_all_completed()}}>Clear completed (<span id=#number_completed class="number-completed">0</span>)</button>
            		</footer>
	    </section>

        Resource.page(title, html)
    }

    function default_page() {
        page_template("TodoMVC")
    }

}
