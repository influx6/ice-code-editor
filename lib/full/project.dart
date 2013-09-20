part of ice;

class Storage{
	String key;
		
	static create(String k) => new Storage(k);
	
	Storage(this.key);
	
	dynamic load(){
		return JSON.parse(window.localStorage[this.key]);
	}
	void sync(json){
		window.localStorage[this.key] = json;
	}
	
}

class Project{
	Pipe stream;
	String id;
	MapDecorator data;
	List history;
	
	static create(key) => new Project(key);
	Project(this.id){
		this.stream = Pipes.create(this.id);
	}
	
	Project load(json){
		this.data = new MapDecorator.from(json);
		data.forEach((k,v){
			var a = this.stream.listen((n){
				this.data.update(k,n);				
			});
			this.stream.add(k,a);
		});
		return this;
	}
	
	void refresh(){
		this.load()
	}
	
	void sync(){
		
	}
	
	void send(item,value){
		
	}
	
	String title => this.data.get('title');
}

//generall idea is to allow multiple projects in a single view,UI needs build,but each element connects to 
//its view and watches for changes and then propagates those changes to appropriate handler through its stream;
class ProjectElement{
	final Streamable pipe = Streamable.create();
	final Streamable sink = Streamable.create();
	Element element;
	String title;
	
	ProjectElement(this.element){
		this.pipe = Streamable.create();
		this.init();
	}
	
	void init(){
		this.element.onChange.listen((e){
			this.generate();
			e.stopPropagation();
			e.preventDefault();
		});
		this.stream.pause();
	}
	
	void generate(){
		this.pipe.send(['lineNumber',this.element.getAttribute('lineNumber')]);
		this.pipe.send(['created_at',this.element.getAttribute('createdAt')]);
		this.pipe.send(['updated_at',Date.now().toString()]);
		this.pipe.send(['code',this.element.innerHTML]);
		this.stream.resume();
	}
}

class ProjectManager{
	String editor = "codeeditor";
	Storage store;
	MapDecorator projects;
	MapDecorator raw;
	static create([k]) => new ProjectManager(k);
	
	ProjectManager([String k]){
		if(k != null) this.editor = k;
		this.store = Storage.create(this.editor);
		this.init();
	}
	
	void init(){
		//first turn array into project maps
		store.load().forEach((n,k){
			this.raw.add(k,v);
			this.projects.add(k,Project.create(k).load(v))
		});
		
	}
	
	void reload(){
		
		this.init();
	}
}